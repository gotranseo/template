import Foundation
import Vapor

struct CSRFVerifier: CSRF {
    func setCSRF(key: String, request: Request) throws -> String {
        let string = "\(try generateRandom())-\(try generateRandom())-\(try generateRandom())-\(try generateRandom())"
        try request.session()[key] = string
        
        return string
    }
    
    func verifyCSRF(submittedToken: String?, key: String, request: Request) throws {
        guard let requiredToken: String = try request.session()[key] else { throw Abort(.forbidden) }
        
        if let token = submittedToken {
            guard token == requiredToken else { throw Abort(.forbidden) }
        } else {
            let _ = try request.content.decode([String: String].self).map(to: Void.self) { form in
                guard let submittedToken: String = form[key] else { throw Abort(.forbidden) }
                guard requiredToken == submittedToken else { throw Abort(.forbidden) }
            }
        }
    }
}
