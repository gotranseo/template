import Vapor
import FluentMySQL
import Foundation

protocol UserRepository: ServiceType {
    func find(id: Int, on connectable: DatabaseConnectable) -> Future<User?>
    func all(on connectable: DatabaseConnectable) -> Future<[User]>
    func find(email: String, on connectable: DatabaseConnectable) -> Future<User?>
    func findCount(email: String, on connectable: DatabaseConnectable) -> Future<Int>
    func save(user: User, on connectable: DatabaseConnectable) -> Future<User>
}

final class MySQLUserRepository: UserRepository {
    static func makeService(for worker: Container) throws -> Self {
        return .init()
    }
    
    func find(id: Int, on connectable: DatabaseConnectable) -> EventLoopFuture<User?> {
        return User.find(id, on: connectable)
    }
    
    func all(on connectable: DatabaseConnectable) -> EventLoopFuture<[User]> {
        return User.query(on: connectable).all()
    }
    
    func find(email: String, on connectable: DatabaseConnectable) -> EventLoopFuture<User?> {
        return User.query(on: connectable).filter(\.email == email).first()
    }
    
    func findCount(email: String, on connectable: DatabaseConnectable) -> EventLoopFuture<Int> {
        return User.query(on: connectable).filter(\.email == email).count()
    }
    
    func save(user: User, on connectable: DatabaseConnectable) -> EventLoopFuture<User> {
        return user.save(on: connectable)
    }
}
