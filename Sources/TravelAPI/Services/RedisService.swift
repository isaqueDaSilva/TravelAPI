//
//  File.swift
//  TravelAPI
//
//  Created by Isaque da Silva on 11/19/25.
//

import Redis
import Vapor

enum RedisService {
    static func setex<T: Encodable>(withKey key: String, value: T, ttl: Int, on connection: Request.Redis) async throws {
        try await connection.setex(.init(key), toJSON: value, expirationInSeconds: ttl)
    }
    
    static func hasAItem(withKey key: String, on connection: Request.Redis) async throws -> Bool {
        try await connection.exists(.init(key)) != 0
    }
}
