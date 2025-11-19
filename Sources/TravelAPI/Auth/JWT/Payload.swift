//
//  Payload.swift
//  TravelAPI
//
//  Created by Isaque da Silva on 11/11/25.
//

import JWT
import Vapor

struct Payload: Content, Authenticatable, JWTPayload {
    let jwtID: IDClaim
    let issuer: IssuerClaim
    let subject: SubjectClaim
    let issuedAt: IssuedAtClaim
    let expiration: ExpirationClaim
    
    func getUserID() throws -> UUID {
        guard let userID = UUID(uuidString: self.subject.value) else {
            throw JWTError.generic(identifier: "Invalid user ID", reason: "The subject claim does not contain a valid UUID.")
        }
        
        return userID
    }
    
    init(with userID: UUID, expirationTime: TimeLimit) throws {
        let issuedAt = Date()
        let randomNumberInString = "\(Int.random(in: .min ... .max))"
        
        let tokenID = userID.uuidString + randomNumberInString + issuedAt.ISO8601Format()
        
        self.jwtID = .init(value: tokenID)
        self.issuer = try .init(value: EnvironmentValues.jwtIssuer())
        self.subject = .init(value: userID.uuidString)
        self.issuedAt = .init(value: issuedAt)
        self.expiration = .init(value: issuedAt.addingTimeInterval(expirationTime.rawValue))
    }
}

extension Payload {
    enum CodingKeys: String, CodingKey {
        case jwtID = "jti"
        case issuer = "iss"
        case subject = "sub"
        case issuedAt = "iat"
        case expiration = "exp"
    }
}

extension Payload {
    func verify(using algorithm: some JWTAlgorithm) async throws {
        try checkIssuer()
        
        try self.checkIssuedAt()
        
        try self.expiration.verifyNotExpired()
    }
}

extension Payload {
    private func checkIssuer() throws {
        let issuerClaim = try EnvironmentValues.jwtIssuer()
        
        guard issuerClaim == self.issuer.value else {
            throw JWTError.generic(identifier: "iss-mismatch", reason: "The \"iss\" claim does not match.")
        }
    }
}

extension Payload {
    private func checkIssuedAt() throws {
        guard self.issuedAt.value < self.expiration.value else {
            throw JWTError.generic(identifier: "iat-in-future", reason: "The \"iat\" claim must not be in the future.")
        }
    }
}

extension Payload {
    enum TimeLimit: TimeInterval {
        case tenMinutes, sevenDays
        
        var rawValue: Double {
            switch self {
            case .tenMinutes:
                return (60 * 10)
            case .sevenDays:
                return (60 * 60 * 24 * 7)
            }
        }
    }
}
