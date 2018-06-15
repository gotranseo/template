import Vapor

public func routes(_ router: Router) throws {
    try router.register(collection: LoginViewController())
    try router.register(collection: MarketingViewController())
    try router.register(collection: RegisterViewController())
}
