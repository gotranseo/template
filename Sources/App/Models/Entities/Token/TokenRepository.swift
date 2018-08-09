import Vapor
import FluentMySQL
import Foundation

protocol TokenRepository: ServiceType {
    
}

final class MySQLTokenRepository: TokenRepository {
    static func makeService(for worker: Container) throws -> Self {
        return .init()
    }
}
