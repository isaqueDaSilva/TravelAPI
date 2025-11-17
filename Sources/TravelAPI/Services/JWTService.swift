//
//  File.swift
//  TravelAPI
//
//  Created by Isaque da Silva on 11/11/25.
//

import JWT
import Vapor

enum JWTService {
    static func generateJWT(
        userID: UUID,
        jwtHandler: Request.JWT
    ) async throws -> String {
        let accessTokenPayload = try Payload(with: userID, expirationTime: .tenMinutes)
        
        return try await jwtHandler.sign(accessTokenPayload)
    }
}

