//
//  File.swift
//  TravelAPI
//
//  Created by Isaque da Silva on 11/19/25.
//

import Vapor

extension HTTPHeaders {
    func getRefreshToken() throws -> String {
        guard let refreshToken = self.first(name: "X-Refresh-Token") else {
            throw HTTPClientError.invalidHeaderFieldValues(["Inavalid field Name: X-Refresh-Token"])
        }
        
        return refreshToken
    }
    
    func getSessionID() throws -> String {
        guard let sessionID = self.first(name: "X-Session-ID") else {
            throw HTTPClientError.invalidHeaderFieldValues(["Inavalid field Name: X-Session-ID"])
        }
        
        return sessionID
    }
}
