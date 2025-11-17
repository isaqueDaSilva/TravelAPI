//
//  File.swift
//  TravelAPI
//
//  Created by Isaque da Silva on 11/17/25.
//

import Vapor

extension GetUserDTO {
    func generateSessionID() -> String {
        let currentDate = Date.now.ISO8601Format().replacingOccurrences(of: ":", with: "")
        let randomNumber = Int.random().description
        let id = self.id.uuidString + currentDate + randomNumber
        
        return id
    }
}
