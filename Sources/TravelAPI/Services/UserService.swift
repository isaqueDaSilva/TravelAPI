//
//  File.swift
//  TravelAPI
//
//  Created by Isaque da Silva on 11/11/25.
//

import Fluent
import FluentPostgresDriver
import Vapor

enum UserService {
    static func createUser(with dto: CreateUserDTO, hashedPassword: String, using connection: any Database) async throws -> GetUserDTO {
        let query = SQLQueryString(stringInterpolation: """
            INSERT into \(ident: User.schema) (\(idents: User.Column.createNewInstanceRows, joinedBy: ", "))
            VALUES (\(bind: dto.name), \(bind: dto.email), \(bind: hashedPassword))
            RETURNING \(idents: User.Column.queryInstanceRows, joinedBy: ", ")
        """)
        
        guard let user = try await (connection as! (any SQLDatabase)).raw(query).first(decoding: GetUserDTO.self) else {
            throw Abort(.internalServerError, reason: "Failed to create user")
        }
        
        return user
    }
    
    static func getUserBy(email: String, using connection: any Database) async throws -> FullUserDTO {
        let userIDParameter = Session.Column.userID.rawValue
        let userIDValueParameter = "\(User.schema).\(User.Column.id.rawValue)"
        
        let query = SQLQueryString(stringInterpolation: """
            SELECT \(idents: User.Column.queryFullInstanceRows, joinedBy: ", "),
            EXISTS (SELECT 1 FROM \(ident: Session.schema) WHERE \(ident: userIDParameter) = \(ident: userIDValueParameter)) AS "hasSession"
            FROM \(ident: User.schema)
            WHERE email = \(bind: email);
        """)
        
        guard let user = try await (connection as! (any SQLDatabase)).raw(query).first(decoding: FullUserDTO.self) else {
            throw Abort(.internalServerError, reason: "No user found with that email")
        }
        
        return user
    }
}
