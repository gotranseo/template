import Vapor
import FluentMySQL
import Foundation

protocol TokenRepository: ServiceType {
    
}

final class MySQLTokenRepository: TokenRepository {    

}

extension MySQLTokenRepository {
    static let serviceSupports: [Any.Type] = [TokenRepository.self]
    
    static func makeService(for worker: Container) throws -> Self {
        return .init()
    }
}
