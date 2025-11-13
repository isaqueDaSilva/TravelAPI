//
//  EnvironmentValues.swift
//  TravelAPI
//
//  Created by Isaque da Silva on 11/11/25.
//

import Vapor

enum EnvironmentValues {
    static func databaseKey() throws -> String {
        guard let databaseKey = Environment.get("DATABASE_URL") else {
            throw Abort(.internalServerError)
        }
        
        return databaseKey
    }
    
    static func jwtIssuer() throws -> String {
        guard let subjectClaim = Environment.get("JWT_ISSUER") else {
            throw Abort(.internalServerError)
        }
        
        return subjectClaim
    }
    
    static func accessTokenSecret() throws -> String {
        guard let jwtSecret = Environment.get("ACCESS_TOKEN_SECRET") else {
            throw Abort(.internalServerError)
        }
        
        return jwtSecret
    }
    
    static func refreshTokenSecret() throws -> String {
        guard let jwtSecret = Environment.get("REFRESH_TOKEN_SECRET") else {
            throw Abort(.internalServerError)
        }
        
        return jwtSecret
    }
}
