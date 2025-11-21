//
//  File.swift
//  TravelAPI
//
//  Created by Isaque da Silva on 11/10/25.
//

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
    }
}

// MARK: Migrations
extension Ride {
    struct Migration: AsyncMigration {
        func prepare(on database: any Database) async throws {
            let passengerSchema = Passenger.schema
            let passengerIDColumn = Passenger.Column.id.rawValue
            let driverSchema = Passenger.schema
            let driverIDColumn = Passenger.Column.id.rawValue
            
            let query = SQLQueryString(stringInterpolation: """
                CREATE TABLE IF NOT EXISTS \(ident: Ride.schema) (
                    \(ident: Column.id.rawValue) UUID PRIMARY KEY DEFAULT gen_random_uuid() UNIQUE NOT NULL,
                    \(ident: Column.passengerID.rawValue) UUID REFERENCES \(ident: passengerSchema)(\(ident: passengerIDColumn)) ON DELETE SET NULL,
                    \(ident: Column.driverID.rawValue) UUID REFERENCES \(ident: driverSchema)(\(ident: driverIDColumn)) ON DELETE SET NULL,
                    \(ident: Column.travelPolyline.rawValue) TEXT NOT NULL,
                    \(ident: Column.distanceInKM.rawValue) DOUBLE PRECISION NOT NULL CHECK (\(unsafeRaw: Column.distanceInKM.rawValue) > 0.0),
                    \(ident: Column.extimatedDurationInMinutes.rawValue) DOUBLE PRECISION NOT NULL CHECK (\(unsafeRaw: Column.extimatedDurationInMinutes.rawValue) > 0.0),
                    \(ident: Column.status.rawValue) \(ident: Status.schema) DEFAULT \(ident: Status.waiting.rawValue) NOT NULL,
                    \(ident: Column.price.rawValue) NUMERIC(6, 2) NULL CHECK (\(unsafeRaw: Column.price.rawValue) > 0.0) NOT NULL,
                    \(ident: Column.isFinished.rawValue) BOOLEAN DEFAULT FALSE NOT NULL,
                    \(ident: Column.finishedDateTime.rawValue) TIMESTAMP,
                    \(ident: Column.createdAt.rawValue) TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
                );
            """)
            
            try await databaseConnection(database).raw(query).run()
        }
        
        func revert(on database: any Database) async throws {
            
        }
    }
    
    struct RidesRequirePassengerOnInsertTrigger: AsyncMigration {
        private let functionName = "rides_require_passenger_on_insert()"
        
        func prepare(on database: any Database) async throws {
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
            
            let sqlDatabase = try databaseConnection(database)
            
            try await sqlDatabase.raw(functionQuery).run()

            try await sqlDatabase.raw(triggerQuery).run()
        }
        
        func revert(on database: any Database) async throws {
            
        }
    }
}
