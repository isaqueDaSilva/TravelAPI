//
//  ProtectedRouteProtocol.swift
//  TravelAPI
//
//  Created by Isaque da Silva on 11/11/25.
//


import Vapor

protocol ProtectedRouteProtocol {
    func userProtectedRoute(by routes: any RoutesBuilder) -> any RoutesBuilder
    func tokenProtectedRoute(with routes: any RoutesBuilder) -> any RoutesBuilder
}

extension ProtectedRouteProtocol {
    func userProtectedRoute(by routes: any RoutesBuilder) -> any RoutesBuilder {
        let userAuthenticator = Authenticator()
        let userGuardMiddleware = GetUserDTO.guardMiddleware()
        
        return routes.grouped(userAuthenticator, userGuardMiddleware)
    }
    
    func tokenProtectedRoute(with routes: any RoutesBuilder) -> any RoutesBuilder {
        let tokenGuardMiddleware = Payload.guardMiddleware()
        
        return routes.grouped(JWTAuthenticator(), tokenGuardMiddleware)
    }
}
