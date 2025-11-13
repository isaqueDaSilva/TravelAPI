//
//  Authenticator.swift
//  TravelAPI
//
//  Created by Isaque da Silva on 11/12/25.
//

import Vapor

struct Authenticator: AsyncBasicAuthenticator {
    func authenticate(basic: BasicAuthorization, for request: Request) async throws {
        let user = try await UserService.getUserBy(email: basic.username, using: request.db)
        
        guard try Bcrypt.verify(basic.password, created: user.passwordHash), !user.hasSession else {
            throw Abort(.unauthorized)
        }
        
        request.auth.login(user.toGetUser())
    }
}
