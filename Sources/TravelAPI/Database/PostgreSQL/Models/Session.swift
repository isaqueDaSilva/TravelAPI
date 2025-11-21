//
//  File.swift
//  TravelAPI
//
//  Created by Isaque da Silva on 11/11/25.
//

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
        
        static var createNewInstanceRows: [String] {
            [
                Self.userID.rawValue,
                Self.refreshToken.rawValue
            ]
        }
        
        static var queryInstanceRows: [String] {
            [
                Self.id.rawValue
            ]
        }
        
        static var queryAllInstancesRows: [String] {
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
                    \(ident: Column.id.rawValue) UUID PRIMARY KEY DEFAULT gen_random_uuid() UNIQUE NOT NULL,
                    \(ident: Column.userID.rawValue) UUID REFERENCES \(ident: userSchema)(\(ident: userIDColumn)) ON DELETE CASCADE NOT NULL,
                    \(ident: Column.refreshToken.rawValue) TEXT UNIQUE NOT NULL,
                    \(ident: Column.createdAt.rawValue) DATE DEFAULT CURRENT_DATE NOT NULL,
                    \(ident: Column.updatedAt.rawValue) TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
                );
            """)
            
            let sqlDatabase = try databaseConnection(database)
            
            try await sqlDatabase.raw(query).run()
        }
        
        func revert(on database: any Database) async throws {
            
        }
    }
    
    struct UpdateLastLoggedDateTriggerFunction: AsyncMigration {
        func prepare(on database: any Database) async throws {
            let updateLastLoggedDateFuntion = "update_last_logged_date()"
            
            let functionQuery = SQLQueryString(stringInterpolation: """
                CREATE OR REPLACE FUNCTION \(unsafeRaw: updateLastLoggedDateFuntion)
                RETURNS TRIGGER AS $$
                BEGIN
                    UPDATE \(ident: User.schema)
                    SET \(ident: User.Column.lastLoggedDate.rawValue) = CURRENT_TIMESTAMP
                    WHERE \(ident: User.Column.id.rawValue) = NEW.\(ident: Column.userID.rawValue);
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
            
            let sqlDatabase = try databaseConnection(database)
            
            try await sqlDatabase.raw(functionQuery).run()

            try await sqlDatabase.raw(triggerQuery).run()
        }
        
        func revert(on database: any Database) async throws {
            
        }
    }
}
