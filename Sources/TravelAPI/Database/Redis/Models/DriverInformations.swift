//
//  File.swift
//  TravelAPI
//
//  Created by Isaque da Silva on 11/21/25.
//

import Vapor

struct DriverInformations: Codable {
    let id: UUID
    let carModel: String
    var isAvailable: Bool
    var currentCity: String
    var currentLongitude: Double
    var currentLatitude: Double
}
