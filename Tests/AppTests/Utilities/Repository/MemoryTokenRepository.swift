@testable import Vapor
@testable import App

class MemoryTokenRepository: TokenRepository {
    let container: Container
    
    init(_ container: Container) {
        self.container = container
    }
}

//MARK: - ServiceType conformance
extension MemoryTokenRepository {
    static let serviceSupports: [Any.Type] = [TokenRepository.self]
    
    static func makeService(for worker: Container) throws -> Self {
        return .init(worker)
    }
}
