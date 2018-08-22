//
//  RegisterViewController.swift
//  App
//
//  Created by Jimmy McDermott on 6/12/18.
//

import Foundation
import Vapor
import Crypto

class RegisterViewController: RouteCollection {
    private let userRepository: UserRepository
    
    init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }
    
    func boot(router: Router) throws {
        router.frontend(.noAuthed) { build in
            build.get("/register", use: registerView)
            build.post(RegisterRequest.self, at: "/register", use: register)
        }
    }
    
    func registerView(req: Request) throws -> Future<View> {
        let context = CSRFContext(csrf: try req.setCSRF())
        return try req.view().render("register", context, request: req)
    }

    func register(req: Request, content: RegisterRequest) throws -> Future<Response> {
        try req.verifyCSRF()
        
        guard content.password == content.confirmPassword else { throw RedirectError(to: "/register", error: "Passwords don't match") }
        let existingUserQuery = userRepository.findCount(email: content.email)
        
        return existingUserQuery.flatMap { count in
            guard count == 0 else { throw RedirectError(to: "/register", error: "A user with that email exists already") }
            
            let hashedPassword = try BCrypt.hash(content.password)
            let newUser = User(name: content.name, email: content.email, password: hashedPassword)
            try newUser.validate()
            
            let response = req.redirect(to: "/home").flash(.success, "Successfully registered", try req.session())
            return self.userRepository.save(user: newUser).transform(to: response)
        }.catchMap { error in
            let errorMessage: String
            if error is ValidationError {
                errorMessage = "Invalid email"
            } else {
                errorMessage = "Something went wrong"
            }
            
            return req.redirect(to: "/register").flash(.error, errorMessage, try req.session())
        }
    }
}
