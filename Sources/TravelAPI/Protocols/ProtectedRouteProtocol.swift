import Vapor

protocol ProtectedRouteProtocol {
    func userProtectedRoute(by routes: RoutesBuilder) -> RoutesBuilder
    func tokenProtectedRoute(with routes: RoutesBuilder) -> RoutesBuilder
}

extension ProtectedRouteProtocol {
    func userProtectedRoute(by routes: RoutesBuilder) -> RoutesBuilder {
        let userAuthenticator = Authenticator()
        let userGuardMiddleware = User.guardMiddleware()
        
        return routes.grouped(userAuthenticator, userGuardMiddleware)
    }
    
    func tokenProtectedRoute(with routes: RoutesBuilder) -> RoutesBuilder {
        let tokenAuthenticator = Payload.authenticator()
        let tokenGuardMiddleware = Payload.guardMiddleware()
        
        return routes.grouped(tokenAuthenticator, tokenGuardMiddleware, TokenAuthenticatorMiddleware())
    }
}