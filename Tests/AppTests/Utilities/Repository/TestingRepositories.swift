@testable import Vapor
@testable import App

public func setupTestingRepositories(services: inout Services, config: inout Config) {
    services.register(MemoryTokenRepository.self)
    services.register(MemoryUserRepository.self)
    
    preferTestingRepositories(config: &config)
}

private func preferTestingRepositories(config: inout Config) {
    config.prefer(MemoryTokenRepository.self, for: TokenRepository.self)
    config.prefer(MemoryUserRepository.self, for: UserRepository.self)
}
