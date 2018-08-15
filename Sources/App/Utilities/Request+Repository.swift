import Vapor

//MARK: - TokenRepository
extension Request {
    func tokenRepository() throws -> TokenRepository {
        return try make()
    }
}

//MARK: - UserRepository
extension Request {
    func userRepository() throws -> UserRepository {
        return try make()
    }
}
