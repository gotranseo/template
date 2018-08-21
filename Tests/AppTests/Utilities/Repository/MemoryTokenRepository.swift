@testable import Vapor
@testable import App

class MemoryTokenRepository: TokenRepository {
    static let serviceSupports: [Any.Type] = [TokenRepository.self]
    
    static func makeService(for worker: Container) throws -> Self {
        return .init()
    }
}
