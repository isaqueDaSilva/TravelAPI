//
//  File.swift
//  TravelAPI
//
//  Created by Isaque da Silva on 11/11/25.
//

import Fluent
import FluentPostgresDriver

enum SessionService {    
    static func createSession(
        with userID: UUID,
        atVerificationCode: String,
        refreshTokenID: String,
        refreshToken: String,
        using connection: any Database
    ) async throws {
        let query = SQLQueryString(stringInterpolation: """
            INSERT INTO \(ident: Session.schema) (\(idents: Session.Column.createNewInstanceRows, joinedBy: ", "))
            VALUES (\(bind: userID), \(bind: atVerificationCode), \(bind: refreshTokenID), \(bind: refreshToken))
        """)
        
        try await (connection as! (any SQLDatabase)).raw(query).run()
    }
}
