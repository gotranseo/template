import Foundation
import Crypto
import Vapor

protocol CSRF: Service {
    func verifyCSRF(submittedToken: String?, key: String, request: Request) throws
    func setCSRF(key: String, request: Request) throws -> String
    func generateRandom() throws -> String
}

extension CSRF {
    func generateRandom() throws -> String {
        return try CryptoRandom().generateData(count: 4).hexEncodedString()
    }
}
