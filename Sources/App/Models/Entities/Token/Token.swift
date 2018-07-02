import Foundation
import Vapor
import FluentMySQL
import Authentication

final class Token: Content {
    var id: Int?
    
    var token: String
    var user_id: User.ID
    
    var deletedAt: Date?
    
    var user: Parent<Token, User> {
        return parent(\.user_id)
    }
    
    init(token: String, user_id: User.ID) {
        self.token = token
        self.user_id = user_id
    }
}

extension Token: MySQLModel {
    static var entity = "tokens"
}

extension Token: Migration {
    typealias Database = MySQLDatabase
    
    static func prepare(on connection: Database.Connection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.reference(from: \.user_id, to: \User.id)
        }
    }
}

extension Token {
    static var deletedAtKey: TimestampKey? = \.deletedAt
}

extension Token: BearerAuthenticatable, Authentication.Token {
    static var userIDKey: WritableKeyPath<Token, Int> {
        return \Token.user_id
    }
    
    static var tokenKey: WritableKeyPath<Token, String> {
        return \Token.token
    }
    
    typealias UserType = User
}
