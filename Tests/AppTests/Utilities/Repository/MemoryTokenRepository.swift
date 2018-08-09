@testable import Vapor
@testable import App

class MemoryTokenRepository: TokenRepository {
    static func makeService(for worker: Container) throws -> Self {
        return .init()
    }
}
