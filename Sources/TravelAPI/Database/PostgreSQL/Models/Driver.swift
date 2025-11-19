//
//  File.swift
//  TravelAPI
//
//  Created by Isaque da Silva on 11/10/25.
//

import Fluent
import FluentPostgresDriver

struct Driver: Sendable {
    static let schema = "drivers"
}

// MARK: Field Names
extension Driver {
    enum Column: String {
        case id = "id"
        case userID = "user_id"
        case carModel = "car_model"
        case isOnline = "is_online"
        case isAvailable = "is_available"
        case createdAt = "created_at"
        
        var key: FieldKey {
            .init(stringLiteral: self.rawValue)
        }
    }
}

// MARK: Migration
extension Driver {
    struct Migration: AsyncMigration {
        func prepare(on database: any Database) async throws {
            try await database.schema(Driver.schema)
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
                    Column.carModel.key,
                    .string,
                    .required
                )
                .field(
                    Column.isOnline.key,
                    .bool,
                    .required,
                    .sql(.default(true))
                )
                .field(
                    Column.isAvailable.key,
                    .bool,
                    .sql(.default(true))
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
            
        }
    }
}
