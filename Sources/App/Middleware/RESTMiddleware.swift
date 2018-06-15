//
//  RESTMiddleware.swift
//  App
//
//  Created by Jimmy McDermott on 6/12/18.
//

import Foundation
import Vapor

class RESTMiddleware: Middleware {
    func respond(to request: Request, chainingTo next: Responder) throws -> EventLoopFuture<Response> {
        let keyStorage = try request.make(KeyStorage.self)
        let unauthedError = Abort(.unauthorized, reason: "Wrong API Key")
        
        guard let headerValue = request.http.headers.firstValue(name: HTTPHeaderName("X-API-KEY")) else { throw unauthedError }
        guard keyStorage.restMiddlewareApiKey == headerValue else { throw unauthedError }
        
        return try next.respond(to: request)
    }
}
