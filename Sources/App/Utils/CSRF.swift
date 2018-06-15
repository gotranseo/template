//
//  CSRF.swift
//  App
//
//  Created by Jimmy McDermott on 6/12/18.
//

import Foundation
//
//  CSRF.swift
//  App
//
//  Created by Jimmy McDermott on 11/7/17.
//

import Foundation
import Vapor
import Crypto

extension Request {
    static let csrfKey = "_csrf"
    
    func verifyCSRF(submittedToken: String? = nil, key: String = Request.csrfKey) throws {
        let validSession = try session()
        guard let requiredToken: String = validSession[key] else { throw Abort(.forbidden) }
        
        if let token = submittedToken {
            guard token == requiredToken else { throw Abort(.forbidden) }
        } else {
            let _ = try content.decode([String: String].self).map(to: Void.self) { form in
                guard let submittedToken: String = form[key] else { throw Abort(.forbidden) }
                guard requiredToken == submittedToken else { throw Abort(.forbidden) }
            }
        }
    }
    
    private func generateRandom() throws -> String {
        return try CryptoRandom().generateData(count: 4).hexEncodedString()
    }
    
    func setCSRF(key: String = Request.csrfKey) throws -> String {
        let string = "\(try generateRandom())-\(try generateRandom())-\(try generateRandom())-\(try generateRandom())"
        try session()[key] = string
        
        return string
    }
}

protocol CSRFViewContext {
    var csrf: String { get set }
}

struct CSRFContext: CSRFViewContext, ViewContext {
    var common: CommonViewContext?
    var csrf: String
    
    init(csrf: String) {
        self.csrf = csrf
    }
}
