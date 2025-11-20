//
//  File.swift
//  TravelAPI
//
//  Created by Isaque da Silva on 11/18/25.
//

import FluentPostgresDriver
import Vapor

func databaseConnection(_ connection: any Database) throws -> any SQLDatabase {
    if let sqlConnection = (connection as? (any SQLDatabase)) {
        return sqlConnection
    } else {
        throw Abort(.internalServerError, reason: "Cannot Possible to create an session at the time. Please try again later.")
    }
}
