import Fluent
import Vapor

func routes(_ app: Application) throws {
    let apiRoute = app.routes.grouped("api")
    
    apiRoute.get { req async in
        "It works!"
    }
    
    try apiRoute.register(collection: AuthController())
}
