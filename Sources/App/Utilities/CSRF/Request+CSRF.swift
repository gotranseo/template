import Foundation
import Vapor

extension Request {
    static let csrfKey = "csrf"
    
    func verifyCSRF(submittedToken: String? = nil, key: String = Request.csrfKey) throws {
        let csrf = try make(CSRF.self)
        return try csrf.verifyCSRF(submittedToken: submittedToken, key: key, request: self)
    }
    
    func setCSRF(key: String = Request.csrfKey) throws -> String {
        let csrf = try make(CSRF.self)
        return try csrf.setCSRF(key: key, request: self)
    }
}
