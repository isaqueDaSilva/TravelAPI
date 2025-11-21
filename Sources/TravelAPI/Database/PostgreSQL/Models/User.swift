//
//  File.swift
//  TravelAPI
//
//  Created by Isaque da Silva on 11/10/25.
//

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
        
        static var createNewInstanceRows: [String] {
            [Self.name.rawValue, Self.email.rawValue, Self.passwordHash.rawValue]
        }
        
        static var queryInstanceRows: [String] {
            [
                Self.id.rawValue,
                Self.name.rawValue,
                Self.email.rawValue
            ]
        }
        
        static var queryFullInstanceRows: [String] {
            [
                Self.id.rawValue,
                Self.email.rawValue,
                Self.name.rawValue,
                Self.passwordHash.rawValue,
                Self.lastLoggedDate.rawValue,
                Self.createdAt.rawValue
            ]
        }
    }
}

// MARK: Migration
extension User {
    struct Migration: AsyncMigration {
        func prepare(on database: any Database) async throws {
            let query = SQLQueryString(stringInterpolation: """
                CREATE TABLE IF NOT EXISTS \(ident: User.schema) (
                    \(ident: Column.id.rawValue) UUID PRIMARY KEY DEFAULT gen_random_uuid() UNIQUE NOT NULL, 
                    \(ident: Column.name.rawValue) TEXT NOT NULL,
                    \(ident: Column.email.rawValue) TEXT UNIQUE NOT NULL CHECK (\(unsafeRaw: Column.email.rawValue) LIKE '%@%_%.%_%'),
                    \(ident: Column.passwordHash.rawValue) TEXT NOT NULL, 
                    \(ident: Column.lastLoggedDate.rawValue) TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
                    \(ident: Column.createdAt.rawValue) DATE DEFAULT CURRENT_DATE NOT NULL
                );
            """)
            
            try await databaseConnection(database).raw(query).run()
        }
        
        func revert(on database: any Database) async throws {
            try await database.schema(User.schema).delete()
        }
    }
    
    struct CreatePassengerProfileTriggerFunction: AsyncMigration {
        func prepare(on database: any Database) async throws {
            let createPassagerProfileFunction = "create_passenger_profile()"
            
            let functionQuery = SQLQueryString(stringInterpolation: """
                CREATE OR REPLACE FUNCTION \(unsafeRaw: createPassagerProfileFunction)
                RETURNS TRIGGER AS $$
                BEGIN
                    INSERT into \(ident: Passenger.schema) (\(idents: Passenger.Column.createNewInstanceRows, joinedBy: ", "))
                    VALUES (NEW.\(ident: Column.id.rawValue))
                    RETURN NEW;
                END;
                $$ LANGUAGE plpgsql;
            """)
            
            let triggerQuery = SQLQueryString(stringInterpolation: """
                CREATE TRIGGER trigger_create_passenger_profile
                AFTER INSERT ON \(ident: User.schema)
                FOR EACH ROW
                EXECUTE FUNCTION \(unsafeRaw: createPassagerProfileFunction);
            """)
            
            let sqlDatabase = try databaseConnection(database)
            
            try await sqlDatabase.raw(functionQuery).run()

            try await sqlDatabase.raw(triggerQuery).run()
        }
        
        func revert(on database: any Database) async throws {
            
        }
    }
}
