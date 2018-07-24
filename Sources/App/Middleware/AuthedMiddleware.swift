import Vapor
import HTTP

final public class AuthedMiddleware: Middleware {
    let jsonResponse: Bool
    
    init(jsonResponse: Bool = false) {
        self.jsonResponse = jsonResponse
    }
    
    public func respond(to request: Request, chainingTo next: Responder) throws -> Future<Response> {
        do {
            let _ = try request.user()
            return try next.respond(to: request)
        } catch {
            try request.destroySession()
            
            if jsonResponse {
                throw Abort(.unauthorized, reason: "Unauthorized user token")
            } else {
                return request.future(request.redirect(to: "/login").flash(.error, "Please login", try request.session()))
            }
        }
    }
}
