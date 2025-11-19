//
//  File.swift
//  TravelAPI
//
//  Created by Isaque da Silva on 11/19/25.
//

import JWT
import Vapor

struct JWTAuthenticator: AsyncBearerAuthenticator {
    func authenticate(bearer: BearerAuthorization, for request: Request) async throws {
        let payload = try await request.jwt.verify(bearer.token, as: Payload.self)
        
        if try await !RedisService.hasAItem(withKey: payload.jwtID.value, on: request.redis) {
            request.auth.login(payload)
        } else {
            throw Abort(.unauthorized)
        }
    }
}
