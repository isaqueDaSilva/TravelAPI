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
    static func generateRawAndHashRefreshToken(from user: GetUserDTO) throws -> (refreshToken: String, refreshTokenHash: String) {
        let refreshToken = user.generateSessionID()
        return (refreshToken: refreshToken, refreshTokenHash: try Bcrypt.hash(refreshToken))
    }
    
    static func createSession(
        with userID: UUID,
        refreshTokenHash: String,
        using connection: any Database
    ) async throws {
        let query = SQLQueryString(stringInterpolation: """
            INSERT INTO \(ident: Session.schema) (\(idents: Session.Column.createNewInstanceRows, joinedBy: ", "))
            VALUES (\(bind: userID), \(bind: refreshTokenHash))
        """)
        
        try await (connection as! (any SQLDatabase)).raw(query).run()
    }
}
