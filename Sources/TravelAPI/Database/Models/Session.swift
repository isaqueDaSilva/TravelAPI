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
        case atVerificationCode = "at_verification_code"
        case refreshTokenID = "refresh_token_id"
        case refreshToken = "refresh_token"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        
        var key: FieldKey {
            .init(stringLiteral: self.rawValue)
        }
        
        static var createNewInstanceRows: [String] {
            [
                Self.userID.rawValue,
                Self.atVerificationCode.rawValue,
                Self.refreshTokenID.rawValue,
                Self.refreshToken.rawValue
            ]
        }
    }
}

// MARK: Migration
extension Session {
    struct Migration: AsyncMigration {
        func prepare(on database: any Database) async throws {
            try await database.schema(Session.schema)
                .field(
                    Column.id.key,
                    .uuid,
                    .required,
                    .identifier(auto: true),
                    .sql(.unique)
                )
                .field(
                    Column.userID.key,
                    .uuid,
                    .required,
                    .references(
                        User.schema,
                        User.Column.id.key,
                        onDelete: .cascade,
                        onUpdate: .cascade
                    ),
                    .sql(.unique)
                )
                .field(
                    Column.atVerificationCode.key,
                    .string,
                    .required,
                    .sql(.unique)
                )
                .field(
                    Column.refreshTokenID.key,
                    .string,
                    .required,
                    .sql(.unique)
                )
                .field(
                    Column.refreshToken.key,
                    .string,
                    .required,
                    .sql(.unique)
                )
                .field(
                    Column.createdAt.key,
                    .date,
                    .required,
                    .sql(.default("CURRENT_DATE"))
                )
                .field(
                    Column.updatedAt.key,
                    .datetime,
                    .required,
                    .sql(.default("CURRENT_TIMESTAMP"))
                )
                .create()
            
            try await addTrigger(at: (database as! (any SQLDatabase)))
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
                    SET \(bind: User.Column.lastLoggedDate.rawValue) = CURRENT_TIMESTAMP
                    WHERE \(bind: User.Column.id.rawValue) = NEW.\(bind: Session.Column.userID.rawValue);
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
