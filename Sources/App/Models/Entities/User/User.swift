import Foundation
import Vapor
import Fluent
import FluentMySQL
import Authentication

final class User: Content {
    var id: Int?
    
    var name: String
    var email: String
    var password: String
    
    var createdAt: Date?
    var updatedAt: Date?
    var deletedAt: Date?
    
    init(name: String, email: String, password: String) {
        self.name = name
        self.email = email
        self.password = password
    }
}

extension User: Validatable {
    static func validations() throws -> Validations<User> {
        var validations = Validations(User.self)
        try validations.add(\.email, .email)
        return validations
    }
}

extension User {
    static var deletedAtKey: TimestampKey? = \.deletedAt
    static var createdAtKey: TimestampKey? = \.createdAt
    static var updatedAtKey: TimestampKey? = \.updatedAt
}

extension User: MySQLModel {
    static var entity = "users"
}

extension User: Parameter { }
extension User: Migration { }
extension User: Authenticatable { }
extension User: SessionAuthenticatable { }

//MARK: - Sessions
extension User {
    private func setSession(session: Session, on connectable: DatabaseConnectable) throws -> User {
        session[Constants.SessionKeys.userEmail] = email
        session[Constants.SessionKeys.userName] = name
        
        if let id = id {
            session[Constants.SessionKeys.userId] = String(id)
        }
        
        return self
    }
    
    
    /// Authenticates the user using sessions and performs necessary login updates
    ///
    /// - Parameters:
    ///   - req: The login request
    ///   - connectable: A connectable object (typically `Request`)
    /// - Returns: the user that was updated. Both instances in the array will be this user)
    func authenticate(req: Request, on connectable: DatabaseConnectable) throws -> Future<User> {
        try req.authenticateSession(self)
        _ = try setSession(session: req.session(), on: connectable)
        
        return self.save(on: connectable)
    }
    
    /// Unauthenticates the user
    ///
    /// - Parameter req: The logout request
    func unauthenticate(req: Request) throws -> Future<Void> {
        try req.unauthenticate(User.self)
        
        let session = try req.session()
        
        if let sessionKey = session.id {
            return try req.keyedCache(for: .redis).remove(sessionKey).flatMap {
                try req.destroySession()
                return .done(on: req)
            }
        }
        
        try req.destroySession()
        return .done(on: req)
    }
}

extension User: TokenAuthenticatable {
    typealias TokenType = Token
}

extension Request {
    func user() throws -> User {
        return try requireAuthenticated(User.self)
    }
}
