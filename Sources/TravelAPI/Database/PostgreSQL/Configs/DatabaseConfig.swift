//
//  File.swift
//  TravelAPI
//
//  Created by Isaque da Silva on 11/17/25.
//

import Fluent
import Vapor

enum DatabaseConfig {
    static func setDatabase(withApp app: Application) throws {
        let databaseKey = try EnvironmentValues.databaseKey()
        
        try app.databases.use(.postgres(url: databaseKey), as: .psql)
    }
    
    static func setMigrations(withMigrations migrations: Migrations) {
        migrations.add(User.Migration())
        migrations.add(Passenger.Migration())
        migrations.add(User.CreatePassengerProfileTriggerFunction())
        migrations.add(Session.Migration())
        migrations.add(Session.UpdateLastLoggedDateTriggerFunction())
        migrations.add(Driver.Migration())
        migrations.add(Status.Migration())
        migrations.add(Ride.Migration())
        migrations.add(Ride.RidesRequirePassengerOnInsertTrigger())
    }
}
