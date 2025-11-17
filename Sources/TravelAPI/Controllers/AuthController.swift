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
        //let userProtectedRoute = userProtectedRoute(by: authRoute)
        
        // -> POST /auth/signup
        authRoute.post("signup") { try await self.signup(with: $0) }
        
        // -> POST /auth/signin
        authRoute.post("signin") { try await self.signin(with: $0) }
    }
    
    @Sendable
    private func signup(with request: Request) async throws -> AuthResponse {
        try CreateUserDTO.validate(content: request)
        
        let createUserDTO = try request.content.decode(CreateUserDTO.self)
        let hashedPassword = try Bcrypt.hash(createUserDTO.password)
        
        
        return try await request.db.transaction { database in
            let newUser = try await UserService.createUser(
                with: createUserDTO,
                hashedPassword: hashedPassword,
                using: database
            )
            
            let accessToken = try await JWTService.generateJWT(userID: newUser.id, jwtHandler: request.jwt)
            let (refreshToken, refreshTokenHash) = try SessionService.generateRawAndHashRefreshToken(from: newUser)
            
            try await SessionService.createSession(
                with: newUser.id,
                refreshTokenHash: refreshTokenHash,
                using: database
            )
            
            return .init(
                userProfile: newUser,
                accessToken: accessToken,
                refreshToken: refreshToken
            )
        }
    }
    
    @Sendable
    private func signin(with request: Request) async throws -> AuthResponse {
        let user = try request.auth.require(GetUserDTO.self)
        
        let accessToken = try await JWTService.generateJWT(userID: user.id, jwtHandler: request.jwt)
        let (refreshToken, refreshTokenHash) = try SessionService.generateRawAndHashRefreshToken(from: user)
        
        try await SessionService.createSession(with: user.id, refreshTokenHash: refreshTokenHash, using: request.db)
        
        return .init(
            userProfile: user,
            accessToken: accessToken,
            refreshToken: refreshToken
        )
    }
}
