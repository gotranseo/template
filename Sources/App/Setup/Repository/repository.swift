import Vapor

public func setupRepositories(services: inout Services) {
    services.register(MySQLTokenRepository())
    services.register(MySQLUserRepository())
}
