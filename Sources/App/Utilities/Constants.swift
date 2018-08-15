//
//  Constants.swift
//  App
//
//  Created by Jimmy McDermott on 6/1/18.
//

import Foundation

struct Constants {
    static let databaseURL = "DATABASE_URL"
    static let redisURL = "REDIS_URL"
    static let restMiddlewareEnvKey = "REST_API_KEY"
    
    struct SessionKeys {
        static let userId = "userId"
        static let userName = "userName"
        static let userEmail = "userEmail"
    }
}
