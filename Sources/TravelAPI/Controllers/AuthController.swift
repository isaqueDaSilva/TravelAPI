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
        
        // -> POST /auth/signup
        authRoute.post("signup") { try await self.signup(with: $0) }
        
        // -> POST /auth/signin
        authRoute.post("signin") { try await self.signin(with: $0) }
    }
    
    @Sendable
    private func signup(with request: Request) async throws -> AuthResponse {
        try CreateUserDTO.validate(query: request)
        
        let createUserDTO = try request.content.decode(CreateUserDTO.self)
        let hashedPassword = try Bcrypt.hash(createUserDTO.password)
        
        
        return try await request.db.transaction { database in
            let newUser = try await UserService.createUser(
                with: createUserDTO,
                hashedPassword: hashedPassword,
                using: database
            )
            
            let pairOfTokens = try await JWTService.createPairOfJWTs(userID: newUser.id, jwtHandler: request.jwt)
            
            try await SessionService.createSession(
                with: newUser.id,
                atVerificationCode: pairOfTokens.validationCode,
                refreshTokenID: pairOfTokens.refreshTokenID,
                refreshToken: pairOfTokens.refreshToken,
                using: database
            )
            
            return .init(
                userProfile: newUser,
                accessToken: pairOfTokens.accessToken,
                refreshTokenID: pairOfTokens.refreshTokenID
            )
        }
    }
    
    @Sendable
    private func signin(with request: Request) async throws -> AuthResponse {
        let user = try request.auth.require(GetUserDTO.self)
        
        let pairOfTokens = try await JWTService.createPairOfJWTs(userID: user.id, jwtHandler: request.jwt)
        
        try await SessionService.createSession(
            with: user.id,
            atVerificationCode: pairOfTokens.validationCode,
            refreshTokenID: pairOfTokens.refreshTokenID,
            refreshToken: pairOfTokens.refreshToken,
            using: request.db
        )
        
        return .init(
            userProfile: user,
            accessToken: pairOfTokens.accessToken,
            refreshTokenID: pairOfTokens.refreshTokenID
        )
    }
}
