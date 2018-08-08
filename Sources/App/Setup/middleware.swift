//
//  middleware.swift
//  App
//
//  Created by Jimmy McDermott on 8/8/18.
//

import Foundation
import Vapor
import VaporSecurityHeaders

public func middleware(config: inout MiddlewareConfig) throws {
    let cspConfig = ContentSecurityPolicyConfiguration(value: CSPConfig.setupCSP().generateString())
    let xssProtectionConfig = XSSProtectionConfiguration(option: .block)
    let contentTypeConfig = ContentTypeOptionsConfiguration(option: .nosniff)
    let frameOptionsConfig = FrameOptionsConfiguration(option: .deny)
    let referrerConfig = ReferrerPolicyConfiguration(.strictOrigin)
    
    let securityHeadersMiddleware = SecurityHeadersFactory()
        .with(contentSecurityPolicy: cspConfig)
        .with(XSSProtection: xssProtectionConfig)
        .with(contentTypeOptions: contentTypeConfig)
        .with(frameOptions: frameOptionsConfig)
        .with(referrerPolicy: referrerConfig)
        .build()
    
    config.use(securityHeadersMiddleware)
    config.use(FileMiddleware.self)
    config.use(TranseoErrorMiddleware.self)
    config.use(SessionsMiddleware.self)
}
