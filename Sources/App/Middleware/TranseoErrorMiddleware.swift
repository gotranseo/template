//
//  TranseoErrorMiddleware.swift
//  App
//
//  Created by Jimmy McDermott on 4/8/18.
//

import Async
import Debugging
import Service
import Foundation
import Vapor
import Leaf
import Fluent

public final class TranseoErrorMiddleware: Middleware, Service {
    
    public init() { }
    
    /// See `Middleware.respond`
    public func respond(to req: Request, chainingTo next: Responder) throws -> Future<Response> {
        do {
            return try next.respond(to: req).flatMap(to: Response.self) { res in
                if res.http.status == .notFound {
                    let view = try req.view()
                    return try self.returnNotFoundPage(view: view, req: req)
                }
                
                return Future.map(on: req) { res }
            }.catchFlatMap { error in
                return try self.handleError(error, req: req)
            }
        } catch {
            return try handleError(error, req: req)
        }
    }
    
    private func handleError(_ error: Swift.Error, req: Request) throws -> Future<Response> {
        //get utility objects
        let environment = req.environment
        let view = try req.view()
        let log = try req.make(Logger.self)
        
        if let redirectError = error as? RedirectError {
            if let error = redirectError.flashError {
                return Future.map(on: req) { req.redirect(to: redirectError.to).flash(.error, error, try req.session()) }
            } else if let success = redirectError.flashSucceed {
                return Future.map(on: req) { req.redirect(to: redirectError.to).flash(.success, success, try req.session()) }
            } else {
                return Future.map(on: req) { req.redirect(to: redirectError.to) }
            }
        } else {
            let reason: String
            let status: HTTPResponseStatus
            
            switch environment {
            case .production:
                
                if let abort = error as? AbortError {
                    reason = abort.reason
                    status = abort.status
                } else if let debuggable = error as? Debuggable {
                    reason = debuggable.reason
                    status = .internalServerError
                } else {
                    status = .internalServerError
                    reason = "Something went wrong."
                }
                
                if req.http.accept.mediaTypes.contains(.html) {
                    //if they want HTML, bail out early and return that view
                    return try returnGenericErrorPage(view: view, req: req, errorCode: status.code, message: "Something went wrong")
                }
            default:
                //always return JSON in development
                if let debuggable = error as? Debuggable {
                    reason = debuggable.reason
                } else if let abort = error as? AbortError {
                    reason = abort.reason
                } else {
                    reason = "Something went wrong."
                }
                
                log.error(reason)
                
                if let abort = error as? AbortError {
                    status = abort.status
                } else {
                    status = .internalServerError
                }
            }
            
            let res = req.makeResponse()
            res.http.status = status
            
            do {
                //If it's a 404, throw the not found
                
                if status == .notFound {
                    return try returnNotFoundPage(view: view, req: req)
                }
                
                //If it's a fluent model not found error
                if let fluentError = error as? FluentError, fluentError.identifier == "modelNotFound" {
                    return try returnNotFoundPage(view: view, req: req)
                }
                
                let errorResponse = ErrorResponse(error: true, reason: reason)
                res.http.body = try HTTPBody(data: JSONEncoder().encode(errorResponse))
                res.http.headers.replaceOrAdd(name: .contentType, value: MediaType.json.description)
            } catch {
                res.http.body = HTTPBody(string: "Oops: \(error)")
                res.http.headers.replaceOrAdd(name: .contentType, value: MediaType.plainText.description)
            }
            
            return Future.map(on: req) { res }
        }
    }
    
    private func returnNotFoundPage(view: ViewRenderer, req: Request) throws -> Future<Response> {
        let res = req.makeResponse()
        
        if req.http.accept.mediaTypes.contains(.html) {
            return try view.render("404", request: req).map(to: Response.self) { view in
                let data = view.data
                res.http.body = HTTPBody(data: data)
                res.http.headers.replaceOrAdd(name: .contentType, value: MediaType.html.description)
                
                return res
            }
        } else {
            let errorResponse = ErrorResponse(error: true, reason: "Not found")
            res.http.body = try HTTPBody(data: JSONEncoder().encode(errorResponse))
            res.http.headers.replaceOrAdd(name: .contentType, value: MediaType.json.description)
            res.http.status = .notFound
            
            return Future.map(on: req) { res }
        }
    }
    
    private func returnGenericErrorPage(view: ViewRenderer, req: Request, errorCode: UInt, message: String) throws -> Future<Response> {
        let res = req.makeResponse()
        let context: [String: String] = ["errorCode": String(errorCode), "message": message]
        
        return view.render("genericerror", context).map(to: Response.self) { view in
            let data = view.data
            res.http.body = HTTPBody(data: data)
            res.http.headers.replaceOrAdd(name: .contentType, value: MediaType.html.description)
            
            return res
        }
    }
}

struct ErrorResponse: Encodable {
    var error: Bool
    var reason: String
}

struct RedirectError: Error {
    let to: String
    let flashError: String?
    let flashSucceed: String?
    
    init(to: String, error: String? = nil, success: String? = nil) {
        self.to = to
        flashError = error
        flashSucceed = success
    }
}
