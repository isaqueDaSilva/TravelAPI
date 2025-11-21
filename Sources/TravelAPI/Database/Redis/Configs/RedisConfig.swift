//
//  File.swift
//  TravelAPI
//
//  Created by Isaque da Silva on 11/19/25.
//

import Redis
import Vapor

enum RedisConfig {
    static func setRedis(with application: Application) throws {
        let redisURL = try EnvironmentValues.redisKey()
        application.redis.configuration = try .init(url: redisURL)
    }
}
