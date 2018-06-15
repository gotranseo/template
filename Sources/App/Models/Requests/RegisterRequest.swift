//
//  RegisterRequest.swift
//  App
//
//  Created by Jimmy McDermott on 6/1/18.
//

import Foundation
import Vapor

struct RegisterRequest: Content {
    let password: String
    let email: String
    let name: String
    let token: String
    let permission: Int
}
