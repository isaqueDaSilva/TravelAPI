//
//  File.swift
//  TravelAPI
//
//  Created by Isaque da Silva on 11/11/25.
//

import Fluent
import FluentPostgresDriver

struct Session: Sendable {
    static let schema = "sessions"
}

// MARK: Columns
extension Session {
    enum Column: String {
        case id = "id"
        case userID = "user_id"
        case refreshToken = "refresh_token_hash"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        
        var key: FieldKey {
            .init(stringLiteral: self.rawValue)
        }
        
        static var createNewInstanceRows: [String] {
            [
                Self.userID.rawValue,
                Self.refreshToken.rawValue
            ]
        }
    }
}

// MARK: Migration
extension Session {
    struct Migration: AsyncMigration {
        func prepare(on database: any Database) async throws {
            let userIDColumn = User.Column.id.rawValue
            let userSchema = User.schema
            
            let query = SQLQueryString(stringInterpolation: """
                CREATE TABLE IF NOT EXISTS \(ident: Session.schema) (
                    \(ident: Session.Column.id.rawValue) UUID PRIMARY KEY DEFAULT gen_random_uuid() UNIQUE NOT NULL,
                    \(ident: Session.Column.userID.rawValue) UUID REFERENCES \(ident: userSchema)(\(ident: userIDColumn)) ON DELETE CASCADE NOT NULL,
                    \(ident: Session.Column.refreshToken.rawValue) TEXT UNIQUE NOT NULL,
                    \(ident: Session.Column.createdAt.rawValue) DATE DEFAULT CURRENT_DATE NOT NULL,
                    \(ident: Session.Column.updatedAt.rawValue) TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
                )
            """)
            
            let sqlDatabase = database as! (any SQLDatabase)
            
            try await sqlDatabase.raw(query).run()
            try await addTrigger(at: sqlDatabase)
        }
        
        func revert(on database: any Database) async throws {
            
        }
        
        private func addTrigger(at database: any SQLDatabase) async throws {
            let updateLastLoggedDateFuntion = "update_last_logged_date()"
            
            let functionQuery = SQLQueryString(stringInterpolation: """
                CREATE OR REPLACE FUNCTION \(unsafeRaw: updateLastLoggedDateFuntion)
                RETURNS TRIGGER AS $$
                BEGIN
                    UPDATE \(ident: User.schema)
                    SET \(ident: User.Column.lastLoggedDate.rawValue) = CURRENT_TIMESTAMP
                    WHERE \(ident: User.Column.id.rawValue) = NEW.\(ident: Session.Column.userID.rawValue);
                    RETURN NEW;
                END;
                $$ LANGUAGE plpgsql;
            """)
            
            let triggerQuery = SQLQueryString(stringInterpolation: """
                CREATE TRIGGER trigger_update_last_logged_date
                AFTER INSERT ON \(ident: Session.schema)
                FOR EACH ROW
                EXECUTE FUNCTION \(unsafeRaw: updateLastLoggedDateFuntion);
            """)
            
            try await database.raw(functionQuery).run()

            try await database.raw(triggerQuery).run()
        }
    }
}
