//
//  LoginViewController.swift
//  App
//
//  Created by Jimmy McDermott on 6/12/18.
//

import Foundation
import Vapor
import Crypto

class LoginViewController: RouteCollection {
    func boot(router: Router) throws {
        router.frontend(.noAuthed) { build in
            build.get("/login", use: loginView)
            build.post(LoginRequest.self, at: "/login", use: login)
        }
        
        router.frontend() { authed in
            authed.get("/logout", use: logout)
        }
    }
    
    func loginView(req: Request) throws -> Future<View> {
        let context = CSRFContext(csrf: try req.setCSRF())
        return try req.view().render("login", context, request: req)
    }

    func login(req: Request, content: LoginRequest) throws -> Future<Response> {
        try req.verifyCSRF()
        
        let repository = try req.userRepository()
        let userQuery = repository
            .find(email: content.email, on: req)
            .unwrap(or: RedirectError(to: "/login", error: "Invalid Credentials"))
        
        return userQuery.flatMap { user in
            if !(try BCrypt.verify(content.password, created: user.password)) {
                throw RedirectError(to: "/login", error: "Invalid Credentials")
            } else {
                let successResponse = req.redirect(to: "/home").flash(.success, "Logged in - Welcome \(user.name)", try req.session())
                return try user.authenticate(req: req, on: req).transform(to: successResponse)
            }
        }
    }
    
    func logout(req: Request) throws -> Future<Response> {
        let user = try req.user()
        
        let response = req.redirect(to: "/login/").flash(.success, "Logged out", try req.session())
        return try user.unauthenticate(req: req).transform(to: response)
    }
}
