//
//  databases.swift
//  App
//
//  Created by Jimmy McDermott on 8/8/18.
//

import Foundation
import FluentMySQL
import Redis
import Vapor

public func databases(config: inout DatabasesConfig) throws {
    guard let redisUrlString = Environment.get(Constants.redisURL) else { throw Abort(.internalServerError) }
    guard let redisUrl = URL(string: redisUrlString) else { throw Abort(.internalServerError) }
    
    let redisConfig = try RedisDatabase(config: RedisClientConfig(url: redisUrl))
    
    guard let databaseUrlString = Environment.get(Constants.databaseURL) else { throw Abort(.internalServerError) }
    guard let mysqlConfig = try MySQLDatabaseConfig(url: databaseUrlString) else { throw Abort(.internalServerError) }
    
    config.add(database: MySQLDatabase(config: mysqlConfig), as: .mysql)
    config.add(database: redisConfig, as: .redis)
}
