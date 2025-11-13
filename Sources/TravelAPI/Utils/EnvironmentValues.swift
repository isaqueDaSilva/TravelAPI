import Vapor

enum EnvironmentValues {
    static func databaseKey() throws -> String {
        guard let databaseKey = Environment.get("DATABASE_URL") else {
            throw Abort(.internalServerError)
        }
        
        return databaseKey
    }
    
    static func jwtIssuer() throws -> String {
        guard let subjectClaim = Environment.get("JWT_ISSUER") else {
            print("JWT_ISSUER was not found.")
            throw Abort(.internalServerError)
        }
        
        return subjectClaim
    }
    
    static func fullAccessJWTAudience() throws -> String {
        guard let jwtSecret = Environment.get("FULL_ACCESS_JWT_AUDIENCE") else {
            throw Abort(.internalServerError)
        }
        
        return jwtSecret
    }
    
    static func refreshJWTAudience() throws -> String {
        guard let jwtSecret = Environment.get("REFRESH_JWT_AUDIENCE") else {
            throw Abort(.internalServerError)
        }
        
        return jwtSecret
    }
    
    static func accessTokenSecret() throws -> String {
        guard let jwtSecret = Environment.get("ACCESS_TOKEN_SECRET") else {
            throw Abort(.internalServerError)
        }
        
        return jwtSecret
    }
    
    static func refreshTokenSecret() throws -> String {
        guard let jwtSecret = Environment.get("REFRESH_TOKEN_SECRET") else {
            throw Abort(.internalServerError)
        }
        
        return jwtSecret
    }
    
    static func jwtSecret() throws -> String {
        guard let jwtSecret = Environment.get("JWT_SECRET") else {
            throw Abort(.internalServerError)
        }
        
        return jwtSecret
    }
    
    static func cupcakeCornerJWTSUB() throws -> String {
        guard let subjectClaim = Environment.get("CUPCAKE_CORNER_JWTSUB") else {
            print("CUPCAKE_CORNER_JWTSUB was not found.")
            throw Abort(.internalServerError)
        }
        
        return subjectClaim
    }
    
    static func tlsCertificatePath() throws -> String {
        guard let tlsPEMCertificatePath = Environment.get("TLS_CERTIFICATE_PATH") else {
            throw Abort(.internalServerError)
        }
        
        return tlsPEMCertificatePath
    }
    
    static func tlsPrivateKey() throws -> String {
        guard let tlsPrivateKey = Environment.get("TLS_KEY_PATH") else {
            throw Abort(.internalServerError)
        }
        
        return tlsPrivateKey
    }
    
    static func productImagePath(with imageName: String) throws -> String {
        guard let cupcakeImageFolder = Environment.get("PRODUCT_IMAGE_FOLDER") else {
            throw Abort(.internalServerError)
        }
        
        return cupcakeImageFolder + "/" + imageName
    }
}
