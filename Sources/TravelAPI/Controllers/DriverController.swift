//
//  File.swift
//  TravelAPI
//
//  Created by Isaque da Silva on 11/20/25.
//

import Vapor

struct DriverController: RouteCollection, ProtectedRouteProtocol {
    func boot(routes: any RoutesBuilder) throws {
        let driverProfileRoute = routes.grouped("driver", "profile")
        let tokenProtectedRoute = tokenProtectedRoute(with: driverProfileRoute)
        
        // POST -> /driver/profile/create
        tokenProtectedRoute.post("create") { try await turnDriver(with: $0) }
        
        // GET -> /driver/profile
        tokenProtectedRoute.get { try await getDriverProfile(with: $0) }
        
        // PATCH -> /driver/profile/update
        tokenProtectedRoute.patch("update") { try await updateCarModel(with: $0) }
        
        // DELETE -> /driver/profile/delete
        tokenProtectedRoute.delete("delete") { try await deleteDriverProfile(with: $0) }
    }
    
    @Sendable
    private func turnDriver(with request: Request) async throws -> Response {
        let payload = try request.auth.require(Payload.self)
        let createDriverDTO = try request.content.decode(DriverProfile.self)
        
        let driverProfileInformations = try await DriverService.createDriver(
            userID: payload.getUserID(),
            carModel: createDriverDTO.carModel,
            using: request.db
        )
        
        let driverProfileInformationsData = try JSONEncoder().encode(driverProfileInformations)
        
        return .init(
            status: .created,
            version: request.version,
            headersNoUpdate: request.headers,
            body: .init(
                data: driverProfileInformationsData
            )
        )
    }
    
    @Sendable
    private func getDriverProfile(with request: Request) async throws -> Response {
        let payload = try request.auth.require(Payload.self)
        
        let driverProfileInformations = try await DriverService.getDriverProfileWith(
            userID: payload.getUserID(),
            using: request.db
        )
        
        let driverProfileInformationsData = try JSONEncoder().encode(driverProfileInformations)
        
        return .init(
            status: .ok,
            version: request.version,
            headersNoUpdate: request.headers,
            body: .init(data: driverProfileInformationsData)
        )
    }
    
    @Sendable
    private func updateCarModel(with request: Request) async throws -> Response {
        let payload = try request.auth.require(Payload.self)
        let updatedInformations = try request.content.decode(DriverProfile.self)
        
        let updatedProfileInformations = try await DriverService.updateCarModelForProfileWith(
            userID: payload.getUserID(),
            newCarModel: updatedInformations.carModel,
            using: request.db
        )
        
        let updatedProfileInformationsData = try JSONEncoder().encode(updatedProfileInformations)
        
        return .init(
            status: .ok,
            version: request.version,
            headersNoUpdate: request.headers,
            body: .init(data: updatedProfileInformationsData)
        )
    }
    
    @Sendable
    private func deleteDriverProfile(with request: Request) async throws -> Response {
        let payload = try request.auth.require(Payload.self)
        
        try await DriverService.deleteProfileFor(userID: payload.getUserID(), using: request.db)
        
        // TODO: Delete informations from Redis
        
        return .init(
            status: .noContent,
            version: request.version,
            headersNoUpdate: request.headers,
            body: .init()
        )
    }
}
