//
//  File.swift
//  TravelAPI
//
//  Created by Isaque da Silva on 11/10/25.
//

import Fluent
import FluentPostgresDriver

struct Location: Sendable {
    static let schema = "locations"
}

// MARK: Field Name
extension Location {
    enum Column: String {
        case id = "id"
        case passengerID = "passenger_id"
        case driverID = "driver_id"
        case cityName = "city_name"
        case currentLatitude = "current_latitude"
        case currentLongitude = "current_longitude"
        case lastUpdate = "last_update"
        
        var key: FieldKey {
            .init(stringLiteral: self.rawValue)
        }
    }
}

// MARK: Migration
extension Location {
    struct Migration: AsyncMigration {
        func prepare(on database: any Database) async throws {
            try await database.schema(Location.schema)
                .field(
                    Column.id.key,
                    .uuid,
                    .required,
                    .identifier(auto: true)
                )
                .field(
                    Column.passengerID.key,
                    .uuid,
                    .references(
                        Passenger.schema,
                        Passenger.Column.id.key,
                        onDelete: .cascade,
                        onUpdate: .cascade
                    ),
                    .sql(.unique)
                )
                .field(
                    Column.driverID.key,
                    .uuid,
                    .references(
                        Driver.schema,
                        Driver.Column.id.key,
                        onDelete: .cascade,
                        onUpdate: .cascade
                    ),
                    .sql(.unique)
                )
                .field(
                    Column.cityName.key,
                    .string,
                    .required
                )
                .field(
                    Column.currentLatitude.key,
                    .int,
                    .required
                )
                .field(
                    Column.currentLongitude.key,
                    .int,
                    .required
                )
                .field(
                    Column.lastUpdate.key,
                    .datetime,
                    .required,
                    .sql(.custom(SQLRaw("CURRENT_TIMESTAMP")))
                )
                .create()
        
            try await addConstraint(with: database as! any SQLDatabase)
        }
        
        func revert(on database: any Database) async throws {
            
        }
        
        private func addConstraint(with database: any SQLDatabase) async throws {
            let checkConstrains = SQLQueryString(stringInterpolation: """
                ALTER TABLE \(unsafeRaw: Location.schema)
                ADD CONSTRAINT locations_xor_passenger_driver
                CHECK (
                    (\(unsafeRaw: Column.passengerID.rawValue) IS NOT NULL AND \(unsafeRaw: Column.driverID.rawValue) IS NULL)
                    OR
                    (\(unsafeRaw: Column.passengerID.rawValue) IS NULL AND \(unsafeRaw: Column.driverID.rawValue) IS NOT NULL))
                );
            """)
            
            try await database.raw(checkConstrains).run()
        }
    }
}
