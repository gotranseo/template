import Vapor

public func routes(_ router: Router, _ container: Container) throws {
    let userRepository = try container.make(UserRepository.self)
    
    try router.register(collection: LoginViewController(userRepository: userRepository))
    try router.register(collection: MarketingViewController())
    try router.register(collection: RegisterViewController(userRepository: userRepository))
}

extension Database {
    public typealias ConnectionPool = DatabaseConnectionPool<ConfiguredDatabase<Self>>
}
