//
//  File.swift
//  TravelAPI
//
//  Created by Isaque da Silva on 11/11/25.
//

import Vapor

typealias CreateUserDTO = User.CreateUser
typealias GetUserDTO = User.GetUser
typealias FullUserDTO = User.FullUser

extension User {
    struct CreateUser: Content, Sendable {
        let name: String
        let email: String
        let password: String
        
        enum CodingKeys: String, CodingKey {
            case name
            case email
            case password
            
            var key: ValidationKey {
                .init(stringLiteral: self.rawValue)
            }
        }
    }
    
    struct GetUser: Content, Sendable, Authenticatable {
        let id: UUID
        let name: String
        let email: String
        let createdAt: Date
    }
    
    struct FullUser: Content, Sendable {
        let id: UUID
        let name: String
        let email: String
        let passwordHash: String
        let hasSession: Bool
        let createdAt: Date
        
        func toGetUser() -> GetUser {
            .init(id: id, name: name, email: email, createdAt: createdAt)
        }
    }
}
