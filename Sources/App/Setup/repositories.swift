//
//  repositories.swift
//  App
//
//  Created by Jimmy McDermott on 8/8/18.
//

import Foundation
import Vapor

public func setupRepositories(services: inout Services, config: inout Config) {
    services.register(MySQLTokenRepository.self)
    services.register(MySQLUserRepository.self)
    
    preferRepositories(config: &config)
}

private func preferRepositories(config: inout Config) {
    config.prefer(MySQLTokenRepository.self, for: TokenRepository.self)
    config.prefer(MySQLUserRepository.self, for: UserRepository.self)
}
