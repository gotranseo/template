//
//  TranseoFlashMiddleware.swift
//  App
//
//  Created by Jimmy McDermott on 6/12/18.
//

import Foundation
import Vapor
import Flash

public struct TranseoFlashMiddleware: Middleware {
    public init() {}
    
    /// See Middleware.respond
    public func respond(to req: Request, chainingTo next: Responder) throws -> Future<Response> {
        try TranseoFlashMiddleware.handle(req: req)
        return try next.respond(to: req).map(to: Response.self) { resp in
            try TranseoFlashMiddleware.handle(req: req, resp: resp)
            return resp
        }.catchMap { error in
            if let redirectError = error as? RedirectError {
                var res = req.redirect(to: redirectError.to)
                
                if let error = redirectError.flashError {
                    res = res.flash(.error, error)
                } else if let success = redirectError.flashSucceed {
                    res = res.flash(.success, success)
                }
                
                try TranseoFlashMiddleware.handle(req: req, resp: res)
                return res
            } else {
                //let theatre error middleware catch it
                throw error
            }
        }
    }
    
    public static func handle(req: Request) throws {
        let session = try req.session()
        
        if let data = session["_flash"]?.data(using: .utf8) {
            let flash = try JSONDecoder().decode(FlashContainer.self, from: data)
            let container = try req.privateContainer.make(FlashContainer.self)
            container.new = flash.new
            container.old = flash.old
        }
    }
    
    public static func handle(req: Request, resp: Response) throws {
        let container = try resp.privateContainer.make(FlashContainer.self)
        let flash = try String(
            data: JSONEncoder().encode(container),
            encoding: .utf8
        )
        try req.session()["_flash"] = flash
    }
}


extension Request {
    func privateView() throws -> ViewRenderer {
        return try privateContainer.make(ViewRenderer.self)
    }
}

extension Request {
    @available(*, deprecated, message: "Use privateView()")
    func view() throws -> ViewRenderer {
        return try make()
    }
}
