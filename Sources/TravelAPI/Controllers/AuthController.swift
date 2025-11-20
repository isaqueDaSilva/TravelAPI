//
//  File.swift
//  TravelAPI
//
//  Created by Isaque da Silva on 11/11/25.
//

import Vapor

struct AuthController: RouteCollection, ProtectedRouteProtocol {
    func boot(routes: any RoutesBuilder) throws {
        let authRoute = routes.grouped("auth")
        let userProtectedRoute = userProtectedRoute(by: authRoute)
        let tokenProtectedRoute = tokenProtectedRoute(with: authRoute)
        
        // -> POST /auth/signup
        authRoute.post("signup") { try await self.signup(with: $0) }
        
        // -> POST /auth/signin
        userProtectedRoute.post("signin") { try await self.signin(with: $0) }
        
        // -> PUT /auth/refresh-token
        authRoute.put("refresh-token") { try await self.refreshToken(with: $0) }
        
        // -> DELETE /auth/signout
        tokenProtectedRoute.delete("signout") { try await self.signout(with: $0) }
        
        // -> DELETE /auth/delete-account
        tokenProtectedRoute.delete("delete-account") { try await self.deleteUser(with: $0) }
    }
    
    @Sendable
    private func signup(with request: Request) async throws -> Response {
        try CreateUserDTO.validate(content: request)
        
        let createUserDTO = try request.content.decode(CreateUserDTO.self)
        let hashedPassword = try Bcrypt.hash(createUserDTO.password)
        
        return try await request.db.transaction { database in
            let newUser = try await UserService.createUser(
                with: createUserDTO,
                hashedPassword: hashedPassword,
                using: database
            )
            
            let authTokens = try await SessionService.buildSession(
                userID: newUser.id,
                jwtHandler: request.jwt,
                at: request.db
            )
            
            let requestBodyData = try JSONEncoder().encode(AuthResponse(userProfile: newUser, tokens: authTokens))
            
            return .init(
                status: .created,
                version: request.version,
                headersNoUpdate: request.headers,
                body: .init(data: requestBodyData)
            )
        }
    }
    
    @Sendable
    private func signin(with request: Request) async throws -> Response {
        let user = try request.auth.require(GetUserDTO.self)
        
        let authTokens = try await SessionService.buildSession(
            userID: user.id,
            jwtHandler: request.jwt,
            at: request.db
        )
        
        let requestBodyData = try JSONEncoder().encode(AuthResponse(userProfile: user, tokens: authTokens))
        
        return .init(
            status: .ok,
            version: request.version,
            headersNoUpdate: request.headers,
            body: .init(data: requestBodyData)
        )
    }
    
    @Sendable
    private func signout(with request: Request) async throws -> Response {
        let payload = try request.auth.require(Payload.self)
        let refreshToken = try request.headers.getRefreshToken()
        let refreshTokenHash = try await SessionService.findSessionWith(userID: payload.getUserID(), using: request.db)
        
        guard try SessionService.checkRefreshToken(refreshToken, with: refreshTokenHash) else {
            throw Abort(.unauthorized)
        }
        
        try await SessionService.deleteSessionWith(userID: payload.getUserID(), using: request.db)
        
        if payload.expiration.value > Date.now {
            try await RedisService.setex(
                withKey: payload.jwtID.value,
                value: request.headers.bearerAuthorization!.token,
                ttl: Int(payload.expiration.value.timeIntervalSinceNow),
                on: request.redis
            )
        }
        
        return .init(status: .noContent, version: request.version, headersNoUpdate: request.headers, body: .init())
    }
    
    @Sendable
    private func deleteUser(with request: Request) async throws -> Response {
        let payload = try request.auth.require(Payload.self)
        let refreshToken = try request.headers.getRefreshToken()
        let refreshTokenHash = try await SessionService.findSessionWith(userID: payload.getUserID(), using: request.db)
        
        guard try SessionService.checkRefreshToken(refreshToken, with: refreshTokenHash) else {
            throw Abort(.unauthorized)
        }
        
        // The user's session is automatically deleted
        // because the table is configured to delete any row
        // in a cascading effect when a user is deleted.
        try await UserService.deleteUser(withID: payload.getUserID(), using: request.db)
        
        if payload.expiration.value > Date.now {
            try await RedisService.setex(
                withKey: payload.jwtID.value,
                value: request.headers.bearerAuthorization!.token,
                ttl: Int(payload.expiration.value.timeIntervalSinceNow),
                on: request.redis
            )
        }
        
        return .init(status: .noContent, version: request.version, headersNoUpdate: request.headers, body: .init())
    }
    
    @Sendable
    private func refreshToken(with request: Request) async throws -> Response {
        let refreshTokenValue = try request.headers.getRefreshToken()
        let sessionID = try request.headers.getSessionID()
        
        return try await request.db.transaction { database in
            let session = try await SessionService.findSessionWith(id: sessionID, using: database)
            
            guard try SessionService.checkRefreshToken(refreshTokenValue, with: session.refreshTokenHash) else {
                throw Abort(.unauthorized)
            }
            
            try await SessionService.deleteSessionWith(id: sessionID, using: database)
            
            let newSession = try await SessionService.buildSession(userID: session.userID, jwtHandler: request.jwt, at: database)
            
            let newSessionData = try JSONEncoder().encode(newSession)
            
            return Response(
                status: .created,
                version: request.version,
                headersNoUpdate: request.headers,
                body: .init(data: newSessionData)
            )
        }
    }
}
