//
//  File.swift
//  TravelAPI
//
//  Created by Isaque da Silva on 11/17/25.
//

import JWT
import Vapor

enum JWTConfig {
    static func setJWT(withApp app: Application) async throws {
        let jwtSecret = try EnvironmentValues.jwtSecret()
        await app.jwt.keys.add(hmac: .init(from: jwtSecret), digestAlgorithm: .sha256)
    }
}
