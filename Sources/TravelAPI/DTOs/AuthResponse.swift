//
//  File.swift
//  TravelAPI
//
//  Created by Isaque da Silva on 11/12/25.
//

import Vapor

struct AuthResponse: Content {
    let userProfile: GetUserDTO
    let accessToken: String
    let refreshTokenID: String
}
