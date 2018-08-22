@testable import Vapor
@testable import App
import Crypto

class MemoryUserRepository: UserRepository {
    let container: Container
    
    init(_ container: Container) {
        self.container = container
    }
    
    func find(id: Int) -> EventLoopFuture<User?> {
        let user = User(name: "", email: "email@email.com", password: try! BCrypt.hash("password"))
        user.id = id
        
        return container.future(user)
    }
    
    func all() -> EventLoopFuture<[User]> {
        return container.future([User(name: "", email: "email@email.com", password: try! BCrypt.hash("password"))])
    }
    
    func find(email: String) -> EventLoopFuture<User?> {
        let user = User(name: "", email: email, password: try! BCrypt.hash("password"))
        user.id = 1
        
        return container.future(user)
    }
    
    func findCount(email: String) -> EventLoopFuture<Int> {
        if email == "email@email.com" {
            return container.future(1)
        } else {
            return container.future(0)
        }
    }
    
    func save(user: User) -> EventLoopFuture<User> {
        let savedUser = user
        savedUser.id = 1
        
        return container.future(savedUser)
    }
}

//MARK: - ServiceType Conformance
extension MemoryUserRepository {
    static let serviceSupports: [Any.Type] = [UserRepository.self]
    
    static func makeService(for worker: Container) throws -> Self {
        return .init(worker)
    }
}
