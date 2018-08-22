import Vapor
import FluentMySQL
import Foundation

protocol UserRepository: ServiceType {
    func find(id: Int) -> Future<User?>
    func all() -> Future<[User]>
    func find(email: String) -> Future<User?>
    func findCount(email: String) -> Future<Int>
    func save(user: User) -> Future<User>
}
