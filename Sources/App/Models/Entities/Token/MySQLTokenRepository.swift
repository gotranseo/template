//
//  MySQLTokenRepository.swift
//  App
//
//  Created by Jimmy McDermott on 8/22/18.
//

import Foundation
import Vapor
import FluentMySQL

final class MySQLTokenRepository: TokenRepository {
    let db: MySQLDatabase.ConnectionPool
    
    init(_ db: MySQLDatabase.ConnectionPool) {
        self.db = db
    }
}

//MARK: - ServiceType Conformance
extension MySQLTokenRepository {
    static let serviceSupports: [Any.Type] = [TokenRepository.self]
    
    static func makeService(for worker: Container) throws -> Self {
        return .init(try worker.connectionPool(to: .mysql))
    }
}
