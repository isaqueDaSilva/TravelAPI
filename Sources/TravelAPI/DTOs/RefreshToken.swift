//
//  File.swift
//  TravelAPI
//
//  Created by Isaque da Silva on 11/19/25.
//

import Vapor

struct RefreshToken: Content {
    let refreshTokenHash: String
    let userID: UUID
}
