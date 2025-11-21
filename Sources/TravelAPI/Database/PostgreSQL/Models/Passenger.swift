//
//  File.swift
//  TravelAPI
//
//  Created by Isaque da Silva on 11/10/25.
//

import FluentPostgresDriver

struct Passenger: Sendable {
    static let schema = "passengers"
}

// MARK: Field Name
extension Passenger {
    enum Column: String {
        case id = "id"
        case userID = "user_id"
        case createdAt = "created_at"
        
        static var createNewInstanceRows: [String] {
            [
                Self.userID.rawValue,
            ]
        }
    }
}

// MARK: Migration
extension Passenger {
    struct Migration: AsyncMigration {
        func prepare(on database: any Database) async throws {
            let userIDColumn = User.Column.id.rawValue
            let userSchema = User.schema
            
            let query = SQLQueryString(stringInterpolation: """
                CREATE TABLE IF NOT EXISTS \(ident: Passenger.schema) (
                    \(ident: Column.id.rawValue) UUID PRIMARY KEY DEFAULT gen_random_uuid() UNIQUE NOT NULL,
                    \(ident: Column.userID.rawValue) UUID REFERENCES \(ident: userSchema)(\(ident: userIDColumn)) ON DELETE CASCADE NOT NULL,
                    \(ident: Column.createdAt.rawValue) TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
                );
            """)
            
            try await databaseConnection(database).raw(query).run()
        }
        
        func revert(on database: any Database) async throws {
            
        }
    }
}
