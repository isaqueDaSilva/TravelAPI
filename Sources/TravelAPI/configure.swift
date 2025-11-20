import NIOSSL
import Fluent
import FluentPostgresDriver
import Vapor

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    try await JWTConfig.setJWT(withApp: app)
    try DatabaseConfig.setDatabase(withApp: app)
    try RedisConfig.setRedis(with: app)
    DatabaseConfig.setMigrations(withMigrations: app.migrations)

    // register routes
    try routes(app)
}
