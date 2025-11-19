//
//  File.swift
//  TravelAPI
//
//  Created by Isaque da Silva on 11/17/25.
//

import Fluent
import FluentPostgresDriver
import Vapor

enum DatabaseConfig {
    static func setDatabase(withApp app: Application) throws {
        let databaseKey = try EnvironmentValues.databaseKey()
        
        try app.databases.use(.postgres(url: databaseKey), as: .psql)
    }
    
    static func setMigrations(withMigrations migrations: Migrations) {
        migrations.add(User.Migration())
        migrations.add(Session.Migration())
    }
}
