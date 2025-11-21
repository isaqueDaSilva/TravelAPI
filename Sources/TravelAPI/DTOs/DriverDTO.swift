//
//  File.swift
//  TravelAPI
//
//  Created by Isaque da Silva on 11/20/25.
//

import Vapor

typealias DriverProfile = Driver.DriverProfile

extension Driver {
    struct DriverProfile: Content {
        let name: String?
        let carModel: String
    }
}
