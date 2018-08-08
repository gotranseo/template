//
//  repositories.swift
//  App
//
//  Created by Jimmy McDermott on 8/8/18.
//

import Foundation
import Vapor

public func setupRepositories(services: inout Services, config: inout Config) {
    services.register(TokenRepository.self) { _ -> MySQLTokenRepository in
        return MySQLTokenRepository()
    }
    
    services.register(UserRepository.self) { _ -> MySQLUserRepository in
        return MySQLUserRepository()
    }
    
    preferTestingRepositories(config: &config)
}

private func preferTestingRepositories(config: inout Config) {
    config.prefer(MySQLTokenRepository.self, for: TokenRepository.self)
    config.prefer(MySQLUserRepository.self, for: UserRepository.self)
}
