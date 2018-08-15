import Foundation
import Vapor

struct EmptyCSRFVerifier: CSRF {
    func verifyCSRF(submittedToken: String?, key: String, request: Request) throws {
        
    }
    func setCSRF(key: String, request: Request) throws -> String {
        return ""
    }
}
