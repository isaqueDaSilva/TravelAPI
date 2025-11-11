//
//  File.swift
//  TravelAPI
//
//  Created by Isaque da Silva on 11/11/25.
//

import Fluent
import Vapor

enum Status: String, Content {
    static let schema = "status"
    
    case waiting = "waiting"
    case accepted = "accepted"
    case inProgress = "in_progress"
    case finished = "finished"
}

// MARK: Migration
extension Status {
    struct Migration: AsyncMigration {
        func prepare(on database: any Database) async throws {
            let _ = try await database.enum(Status.schema)
                .case(Status.waiting.rawValue)
                .case(Status.accepted.rawValue)
                .case(Status.inProgress.rawValue)
                .case(Status.finished.rawValue)
                .create()
        }
        
        func revert(on database: any Database) async throws {
            
        }
    }
}
