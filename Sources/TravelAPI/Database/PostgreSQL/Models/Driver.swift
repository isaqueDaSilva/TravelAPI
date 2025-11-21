//
//  File.swift
//  TravelAPI
//
//  Created by Isaque da Silva on 11/10/25.
//

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
        case createdAt = "created_at"
        
        static var createNewInstanceRows: [String] {
            [
                Self.userID.rawValue,
                Self.carModel.rawValue
            ]
        }
        
        static var queryInstanceRows: [String] {
            [
                Self.carModel.rawValue,
            ]
        }
    }
}

// MARK: Migration
extension Driver {
    struct Migration: AsyncMigration {
        func prepare(on database: any Database) async throws {
            let userIDColumn = User.Column.id.rawValue
            let userSchema = User.schema
            
            let query = SQLQueryString(stringInterpolation: """
                CREATE TABLE IF NOT EXISTS \(ident: Driver.schema) (
                    \(ident: Column.id.rawValue) UUID PRIMARY KEY DEFAULT gen_random_uuid() UNIQUE NOT NULL, 
                    \(ident: Column.userID.rawValue) UUID REFERENCES \(ident: userSchema)(\(ident: userIDColumn)) ON DELETE CASCADE NOT NULL,
                    \(ident: Column.carModel.rawValue) TEXT NOT NULL, 
                    \(ident: Column.createdAt.rawValue) DATE DEFAULT CURRENT_DATE NOT NULL
                );
            """)
            
            try await databaseConnection(database).raw(query).run()
        }
        
        func revert(on database: any Database) async throws {
            
        }
    }
}
