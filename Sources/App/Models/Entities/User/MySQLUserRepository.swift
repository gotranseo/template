//
//  MySQLUserRepository.swift
//  App
//
//  Created by Jimmy McDermott on 8/22/18.
//

import Foundation
import Vapor
import FluentMySQL

final class MySQLUserRepository: UserRepository {
    let db: MySQLDatabase.ConnectionPool
    
    init(_ db: MySQLDatabase.ConnectionPool) {
        self.db = db
    }
    
    func find(id: Int) -> EventLoopFuture<User?> {
        return db.withConnection { conn in
            return User.find(id, on: conn)
        }
    }
    
    func all() -> EventLoopFuture<[User]> {
        return db.withConnection { conn in
            return User.query(on: conn).all()
        }
    }
    
    func find(email: String) -> EventLoopFuture<User?> {
        return db.withConnection { conn in
            return User.query(on: conn).filter(\.email == email).first()
        }
    }
    
    func findCount(email: String) -> EventLoopFuture<Int> {
        return db.withConnection { conn in
            return User.query(on: conn).filter(\.email == email).count()
        }
    }
    
    func save(user: User) -> EventLoopFuture<User> {
        return db.withConnection { conn in
            return user.save(on: conn)
        }
    }
}

//MARK: - ServiceType Conformance
extension MySQLUserRepository {
    static let serviceSupports: [Any.Type] = [UserRepository.self]
    
    static func makeService(for worker: Container) throws -> Self {
        return .init(try worker.connectionPool(to: .mysql))
    }
}
