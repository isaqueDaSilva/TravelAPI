//
//  File.swift
//  TravelAPI
//
//  Created by Isaque da Silva on 11/11/25.
//

import JWT
import Vapor

enum JWTService {
    static func createPairOfJWTs(
        userID: UUID,
        jwtHandler: Request.JWT
    ) async throws -> (accessToken: String, refreshToken: String, validationCode: String, refreshTokenID: String) {
        let validationCode = UUID().uuidString
        let accessTokenPayload = try Payload(with: userID, validationCode: validationCode, expirationTime: .tenMinutes)
        let refreshTokenPayload = try Payload(with: userID, validationCode: validationCode, expirationTime: .sevenDays)
        
        let accessToken = try await jwtHandler.sign(accessTokenPayload)
        let refreshToken = try await jwtHandler.sign(refreshTokenPayload)
        
        return (
            accessToken: accessToken,
            refreshToken: refreshToken,
            validationCode: validationCode,
            refreshTokenID: refreshTokenPayload.jwtID.value
        )
    }
}

