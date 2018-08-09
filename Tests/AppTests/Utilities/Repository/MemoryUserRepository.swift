@testable import Vapor
@testable import App
import Crypto

class MemoryUserRepository: UserRepository {
    static func makeService(for worker: Container) throws -> Self {
        return .init()
    }
    
    func find(id: Int, on connectable: DatabaseConnectable) -> EventLoopFuture<User?> {
        let user = User(name: "", email: "email@email.com", password: try! BCrypt.hash("password"))
        user.id = id
        
        return connectable.future(user)
    }
    
    func all(on connectable: DatabaseConnectable) -> EventLoopFuture<[User]> {
        return connectable.future([User(name: "", email: "email@email.com", password: try! BCrypt.hash("password"))])
    }
    
    func find(email: String, on connectable: DatabaseConnectable) -> EventLoopFuture<User?> {
        let user = User(name: "", email: email, password: try! BCrypt.hash("password"))
        user.id = 1
        
        return connectable.future(user)
    }
    
    func findCount(email: String, on connectable: DatabaseConnectable) -> EventLoopFuture<Int> {
        if email == "email@email.com" {
            return connectable.future(1)
        } else {
            return connectable.future(0)
        }
    }
    
    func save(user: User, on connectable: DatabaseConnectable) -> EventLoopFuture<User> {
        let savedUser = user
        savedUser.id = 1
        
        return connectable.future(savedUser)
    }
}
