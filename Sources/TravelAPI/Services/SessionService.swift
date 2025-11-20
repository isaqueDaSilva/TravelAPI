//
//  File.swift
//  TravelAPI
//
//  Created by Isaque da Silva on 11/11/25.
//

import Fluent
import FluentPostgresDriver
import Vapor

enum SessionService {
    static func generateRawAndHashRefreshToken() throws -> (refreshToken: String, refreshTokenHash: String) {
        let currentDate = Date.now.ISO8601Format().replacingOccurrences(of: ":", with: "")
        let randomNumber = Int.random().description
        let refreshToken = currentDate + randomNumber
        return (refreshToken: refreshToken, refreshTokenHash: try Bcrypt.hash(refreshToken))
    }
    
    static func checkRefreshToken(_ refreshToken: String, with refreshTokenHash: String) throws -> Bool {
        try Bcrypt.verify(refreshToken, created: refreshTokenHash)
    }
    
    
    static func buildSession(userID: UUID, jwtHandler: Request.JWT, at database: any Database) async throws -> AuthTokens {
        let accessToken = try await JWTService.generateJWT(userID: userID, jwtHandler: jwtHandler)
        let (refreshToken, refreshTokenHash) = try SessionService.generateRawAndHashRefreshToken()
        
        let sessionID = try await SessionService.createSession(
            with: userID,
            refreshTokenHash: refreshTokenHash,
            using: database
        )
        
        return AuthTokens(
            accessToken: accessToken,
            refreshToken: refreshToken,
            sessionID: sessionID
        )
    }
    
    static func createSession(
        with userID: UUID,
        refreshTokenHash: String,
        using connection: any Database
    ) async throws -> UUID {
        let query = SQLQueryString(stringInterpolation: """
            INSERT INTO \(ident: Session.schema) (\(idents: Session.Column.createNewInstanceRows, joinedBy: ", "))
            VALUES (\(bind: userID), \(bind: refreshTokenHash))
            RETURNING (\(idents: Session.Column.queryInstanceRows, joinedBy: ", "))
        """)
        
        guard let sessionID = try await databaseConnection(connection).raw(query).first(decoding: UUID.self) else {
            throw PostgresError.protocol("Failed to create a new session. No id was returned.")
        }
        
        return sessionID
    }
    
    static func findSessionWith(userID: UUID, using connection: any Database) async throws -> String {
        let query = SQLQueryString(stringInterpolation: """
            SELECT \(ident: Session.Column.refreshToken.rawValue) FROM \(ident: Session.schema)
            WHERE \(ident: Session.Column.userID.rawValue) = \(bind: userID)
        """)
        
        guard let refreshToken = try await databaseConnection(connection).raw(query).first(decoding: String.self) else {
            throw PostgresError.protocol("No session found for the given user ID.")
        }
        
        return refreshToken
    }
    
    static func findSessionWith(id: String, using connection: any Database) async throws -> RefreshToken {
        let refreshTokenColumn = Session.Column.refreshToken.rawValue
        let userIDColumn = Session.Column.userID.rawValue
        
        let query = SQLQueryString(stringInterpolation: """
            SELECT \(ident: refreshTokenColumn) AS "refreshTokenHash", \(ident: userIDColumn) AS "userID" FROM \(ident: Session.schema)
            WHERE \(ident: Session.Column.id.rawValue) = \(bind: id)
        """)
        
        guard let refreshToken = try await databaseConnection(connection).raw(query).first(decoding: RefreshToken.self) else {
            throw PostgresError.protocol("No session found for the given user ID.")
        }
        
        return refreshToken
    }
    
    static func deleteSessionWith(userID: UUID, using connection: any Database) async throws {
        let query = SQLQueryString(stringInterpolation: """
            DELETE FROM \(ident: Session.schema)
            WHERE \(ident: Session.Column.userID.rawValue) = \(bind: userID)
        """)
        
        try await databaseConnection(connection).raw(query).run()
    }
    
    static func deleteSessionWith(id: String, using connection: any Database) async throws {
        let query = SQLQueryString(stringInterpolation: """
            DELETE FROM \(ident: Session.schema)
            WHERE \(ident: Session.Column.id.rawValue) = \(bind: id)
        """)
        
        try await databaseConnection(connection).raw(query).run()
    }
}
