//
//  TranseoFlashMiddleware.swift
//  App
//
//  Created by Jimmy McDermott on 7/17/18.
//

import Foundation
import Vapor
import Flash

final class TranseoFlashMiddleware: Middleware {
    func respond(to request: Request, chainingTo next: Responder) throws -> EventLoopFuture<Response> {
        let flashContainer = try request.make(FlashContainer.self)
        
        if flashContainer.flashes.count > 0 {
            let session = try request.session()
            let encoder = JSONEncoder()
            let data = try encoder.encode(flashContainer.flashes)
            
            session["_flash"] = String(data: data, encoding: .utf8)
        }
        
        flashContainer.clear()
        
        return try next.respond(to: request)
    }
}
