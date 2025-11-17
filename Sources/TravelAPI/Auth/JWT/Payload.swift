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
    
    var userID: UUID? {
        .init(uuidString: self.subject.value)
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
            throw Abort(.unauthorized)
        }
    }
}

extension Payload {
    private func checkIssuedAt() throws {
//        let timeLimit: TimeInterval = if self.audience.value[0] == "0" {
//            TimeLimit.tenMinutes.rawValue
//        } else if self.audience.value[0] == "1" {
//            TimeLimit.sevenDays.rawValue
//        } else {
//            throw Abort(.unauthorized)
//        }
        
//        let issuedAt = self.issuedAt.value
//        let pastTime = Date().addingTimeInterval(-timeLimit)
//        let expirationTime = issuedAt.addingTimeInterval(timeLimit)
//        
//        guard (issuedAt >= pastTime) && (expirationTime == self.expiration.value) else {
//            throw Abort(.unauthorized)
//        }
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
