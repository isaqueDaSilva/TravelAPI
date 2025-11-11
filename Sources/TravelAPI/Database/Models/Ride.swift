//
//  File.swift
//  TravelAPI
//
//  Created by Isaque da Silva on 11/10/25.
//

import Fluent
import FluentPostgresDriver

struct Ride: Sendable {
    static let schema = "rides"
}


// MARK: Field Names
extension Ride {
    enum Column: String {
        case id = "id"
        case passengerID = "passenger_id"
        case driverID = "driver_id"
        case travelPolyline = "travel_polyline"
        case distanceInKM = "distance_in_km"
        case extimatedDurationInMinutes = "estimated_duration_in_minutes"
        case status = "status"
        case price = "price"
        case isFinished = "is_finished"
        case finishedDateTime = "finished_date_time"
        case createdAt = "created_at"
        
        var key: FieldKey {
            .init(stringLiteral: self.rawValue)
        }
    }
}

// MARK: Migrations
extension Ride {
    struct Migration: AsyncMigration {
        func prepare(on database: any Database) async throws {
            let statusEnum = try await database.enum(Status.schema).read()
            
            try await database.schema(Ride.schema)
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
                        onDelete: .setNull,
                        onUpdate: .cascade
                    )
                )
                .field(
                    Column.driverID.key,
                    .uuid,
                    .references(
                        Driver.schema,
                        Driver.Column.id.key,
                        onDelete: .setNull,
                        onUpdate: .cascade
                    )
                )
                .field(
                    Column.travelPolyline.key,
                    .string,
                    .required
                )
                .field(
                    Column.distanceInKM.key,
                    .double,
                    .required,
                    .sql(
                        .check(
                            SQLQueryString(stringInterpolation: "\(unsafeRaw: Column.distanceInKM.rawValue) > 0.0")
                        )
                    )
                )
                .field(
                    Column.extimatedDurationInMinutes.key,
                    .double,
                    .required,
                    .sql(
                        .check(
                            SQLQueryString(stringInterpolation: "\(unsafeRaw: Column.extimatedDurationInMinutes.rawValue) > 0.0")
                        )
                    )
                )
                .field(
                    Column.status.key,
                    statusEnum,
                    .required,
                    .sql(.default(SQLRaw("'\(Status.waiting.rawValue)'")))
                )
                .field(
                    Column.price.key,
                    .double,
                    .required,
                    .sql(
                        .check(
                            SQLQueryString(stringInterpolation: "\(unsafeRaw: Column.price.rawValue) > 0.0")
                        )
                    )
                )
                .field(
                    Column.isFinished.key,
                    .bool,
                    .required,
                    .sql(.default(false))
                )
                .field(
                    Column.finishedDateTime.key,
                    .datetime
                )
                .field(
                    Column.createdAt.key,
                    .datetime,
                    .required,
                    .sql(.custom(SQLRaw("CURRENT_TIMESTAMP")))
                )
                .create()
        }
        
        func revert(on database: any Database) async throws {
            
        }
        
        private func addTrigger(at database: any SQLDatabase) async throws {
            let functionName = "rides_require_passenger_on_insert()"
            
            let functionQuery = SQLQueryString(stringInterpolation: """
                CREATE OR REPLACE FUNCTION \(unsafeRaw: functionName)
                RETURNS trigger AS $$
                BEGIN
                    IF NEW.\(unsafeRaw: Column.passengerID.rawValue) IS NULL THEN
                        RAISE EXCEPTION 'passenger_id is required to create a new ride.';
                    END IF;
                    RETURN NEW;
                END;
                $$ LANGUAGE plpgsql;
            """)
            
            let triggerQuery = SQLQueryString(stringInterpolation: """
                CREATE TRIGGER trg_rides_require_passenger_on_insert
                BEFORE INSERT ON \(unsafeRaw: Ride.schema)
                FOR EACH ROW
                EXECUTE FUNCTION \(unsafeRaw: functionName);
            """)
            
            try await database.raw(functionQuery).run()

            try await database.raw(triggerQuery).run()
        }
    }
}
