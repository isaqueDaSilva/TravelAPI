//
//  File.swift
//  TravelAPI
//
//  Created by Isaque da Silva on 11/10/25.
//

import Fluent
import FluentPostgresDriver

struct User: Sendable {
    static let schema = "users"
}

// MARK: Field Name
extension User {
    enum Column: String {
        case id = "id"
        case name = "name"
        case email = "email"
        case passwordHash = "password_hash"
        case lastLoggedDate = "last_logged_date"
        case createdAt = "created_at"
        
        var key: FieldKey {
            .init(stringLiteral: self.rawValue)
        }
        
        static var createNewInstanceRows: [String] {
            [Self.name.rawValue, Self.email.rawValue, Self.passwordHash.rawValue]
        }
        
        static var queryInstanceRows: [String] {
            [
                Self.id.rawValue,
                Self.name.rawValue,
                Self.email.rawValue,
                "\(Self.createdAt.rawValue) AS \"createdAt\""
            ]
        }
        
        static var queryFullInstanceRows: [String] {
            [
                Self.id.rawValue,
                Self.email.rawValue,
                Self.name.rawValue,
                "\(Self.passwordHash.rawValue) AS \"passwordHash\"",
                "\(Self.lastLoggedDate.rawValue) AS \"lastLoggedDate\"",
                "\(Self.createdAt.rawValue) AS \"createdAt\""
            ]
        }
    }
}

// MARK: Migration
extension User {
    struct Migration: AsyncMigration {
        func prepare(on database: any Database) async throws {
            let checkEmail = SQLQueryString(
                stringInterpolation: "\(unsafeRaw: Column.email.rawValue) LIKE '%@%_%.%_%'"
            )
            
            try await database.schema(User.schema)
                .field(
                    Column.id.key,
                    .uuid,
                    .required,
                    .identifier(auto: true),
                    .sql(.unique)
                )
                .field(
                    Column.name.key,
                    .string,
                    .required
                )
                .field(
                    Column.email.key,
                    .string,
                    .required,
                    .sql(.unique),
                    .sql(.check(checkEmail)),
                )
                .field(
                    Column.passwordHash.key,
                    .string,
                    .required
                )
                .field(
                    Column.lastLoggedDate.key,
                    .datetime,
                    .required,
                    .sql(.custom(SQLRaw("CURRENT_TIMESTAMP")))
                )
                .field(
                    Column.createdAt.key,
                    .date,
                    .required,
                    .sql(.custom(SQLRaw("CURRENT_DATE")))
                )
                .create()
        }
        
        func revert(on database: any Database) async throws {
            try await database.schema(User.schema).delete()
        }
    }
}
