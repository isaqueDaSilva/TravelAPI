//
//  File.swift
//  TravelAPI
//
//  Created by Isaque da Silva on 11/20/25.
//

import FluentPostgresDriver

enum DriverService {
    static func createDriver(userID: UUID, carModel: String, using connection: any Database) async throws -> DriverProfile {
        let query = SQLQueryString(stringInterpolation: """
            INSERT into \(ident: Driver.schema) (\(idents: Driver.Column.createNewInstanceRows, joinedBy: ", "))
            VALUES (\(bind: userID), \(bind: carModel))
            RETURNING \(idents: Driver.Column.queryInstanceRows, joinedBy: ", ");
        """)
        
        let decoder = SQLRowDecoder(keyDecodingStrategy: .convertFromSnakeCase)
        
        guard let driverInformations = try await databaseConnection(connection).raw(query).first(
            decoding: DriverProfile.self,
            with: decoder
        ) else {
            throw PostgresError.protocol("No data was created.")
        }
        
        return driverInformations
    }
    
    static func getDriverProfileWith(userID: UUID, using connection: any Database) async throws -> DriverProfile {
        let userNameParameter = User.Column.name.rawValue
        
        let query = SQLQueryString(stringInterpolation: """
            SELECT \(idents: Driver.Column.queryInstanceRows, joinedBy: ", ")
            FROM \(ident: Driver.schema)
            INNER JOIN \(ident: User.schema) ON \(ident: Driver.schema).name = \(ident: User.schema).\(ident: userNameParameter)
            WHERE \(ident: Driver.Column.id.rawValue) = \(bind: userID);
        """)
        
        let decoder = SQLRowDecoder(keyDecodingStrategy: .convertFromSnakeCase)
        
        guard let driverInformations = try await databaseConnection(connection).raw(query).first(
            decoding: DriverProfile.self,
            with: decoder
        ) else {
            throw PostgresError.protocol("No data was founded for the given user ID.")
        }
        
        return driverInformations
    }
    
    static func updateCarModelForProfileWith(userID: UUID, newCarModel: String, using connection: any Database) async throws -> DriverProfile {
        let query = SQLQueryString(stringInterpolation: """
            UPDATE \(ident: Driver.schema)
            SET \(ident: Driver.Column.carModel.rawValue) = \(bind: newCarModel)
            WHERE \(ident: Driver.Column.userID.rawValue) = \(bind: userID);
        """)
        
        let decoder = SQLRowDecoder(keyDecodingStrategy: .convertFromSnakeCase)
        
        guard let updatedDriverInformations = try await databaseConnection(connection).raw(query).first(
            decoding: DriverProfile.self,
            with: decoder
        ) else {
            throw PostgresError.protocol("No data was founded for the given user ID.")
        }
        
        return updatedDriverInformations
    }
    
    static func deleteProfileFor(userID: UUID, using connection: any Database) async throws {
        let query = SQLQueryString(stringInterpolation: """
            DELETE FROM \(ident: Driver.schema)
            WHERE \(ident: Driver.Column.id.rawValue) = \(bind: userID);
        """)
        
        try await databaseConnection(connection).raw(query).run()
    }
}
