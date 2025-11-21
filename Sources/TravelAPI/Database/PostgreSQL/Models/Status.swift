//
//  File.swift
//  TravelAPI
//
//  Created by Isaque da Silva on 11/11/25.
//

import FluentPostgresDriver
import Vapor

enum Status: String, Content {
    static let schema = "status"
    
    case waiting = "waiting"
    case accepted = "accepted"
    case inProgress = "in_progress"
    case finished = "finished"
    
    static var allColumns: [String] {
        [
            "'\(Self.waiting.rawValue)'",
            "'\(Self.accepted.rawValue)'",
            "'\(Self.inProgress.rawValue)'",
            "'\(Self.finished.rawValue)'"
        ]
    }
}

// MARK: Migration
extension Status {
    struct Migration: AsyncMigration {
        func prepare(on database: any Database) async throws {
            let query = SQLQueryString(stringInterpolation: """
                CREATE TYPE \(ident: Status.schema) AS ENUM (\(idents: Status.allColumns, joinedBy: ", "));
            """)
            
            try await databaseConnection(database).raw(query).run()
        }
        
        func revert(on database: any Database) async throws {
            
        }
    }
}
