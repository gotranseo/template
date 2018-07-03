import Vapor
import Foundation
@testable import App
import XCTest
import FluentMySQL
import Leaf

extension Application {
    static func testable(envArgs: [String]? = nil, capturing: Bool = false, preferMemoryRepositories: Bool = true) throws -> Application {
        var config = Config.default()
        var services = Services.default()
        var env = Environment.testing
        
        if let args = envArgs {
            env.arguments = args
        }
        
        try App.configure(&config, &env, &services)
        
        if capturing {
            try services.register(CapturingViewProvider())
            config.prefer(CapturingViewRenderer.self, for: ViewRenderer.self)
        }

        //Register a mock logger to nuke all of the annoying logs
        services.register(Logger.self) { container -> MockLogger in
            return MockLogger()
        }
        
        services.register(CSRF.self) { _ -> EmptyCSRFVerifier in
            return EmptyCSRFVerifier()
        }
        
        config.prefer(MockLogger.self, for: Logger.self)
        config.prefer(EmptyCSRFVerifier.self, for: CSRF.self)
        
        if preferMemoryRepositories {
            setupTestingRepositories(services: &services, config: &config)
        }
        
        let app = try Application(config: config, environment: env, services: services)
        
        try App.boot(app)
        return app
    }
    
    static func reset() throws {
        let revertEnvironment = ["vapor", "revert", "--all", "-y"]
        try Application.testable(envArgs: revertEnvironment).asyncRun().wait()
    }
    
    func getResponse<T: Content, U: Decodable>(to path: String, method: HTTPMethod = .GET, headers: HTTPHeaders = .init(), body: T? = nil, contentType: MediaType? = nil, decodeTo type: U.Type) throws -> U {
        let response = try self.sendRequest(to: path, method: method, headers: headers, data: body, contentType: contentType)
        return try response.content.decode(type).wait()
    }
    
    func sendRequest<T: Content>(to path: String, method: HTTPMethod, headers: HTTPHeaders = [:], data: T? = nil, contentType: MediaType? = nil) throws -> Response {
        let request = HTTPRequest(method: method, url: URL(string: path)!, headers: headers)
        return try sendRequest(request: request, content: data, contentType: contentType)
    }
    
    func sendRequest<T: Content>(request: HTTPRequest, content: T? = nil, contentType: MediaType? = nil) throws -> Response {
        let wrappedRequest = Request(http: request, using: self)
        
        if let content = content, let contentType = contentType {
            try wrappedRequest.content.encode(content, as: contentType)
        }
        
        return try sendRequest(request: wrappedRequest)
    }
    
    func sendRequest(request: Request) throws -> Response {
        let responder = try self.make(Responder.self)
        return try responder.respond(to: request).wait()
    }
    
    func sendGetRequest(to path: String, headers: HTTPHeaders = [:]) throws -> Response {
        let request = HTTPRequest(method: .GET, url: URL(string: path)!, headers: headers)
        let wrappedRequest = Request(http: request, using: self)
        return try sendRequest(request: wrappedRequest)
    }
}
