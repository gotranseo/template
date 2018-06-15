//
//  CSPConfig.swift
//  App
//
//  Created by Jimmy McDermott on 6/11/18.
//

import Foundation

struct CSPConfig {
    static func setupCSP(includeViolationUrl: Bool = true) -> CSPBuilder {
        let contentSecurityPolicy = CSPBuilder()
        
        //default-src
        var defaultSrc = DefaultSrc()
        defaultSrc.addDirective(directive: .self)
        
        //connect-src
        var connectSrc = ConnectSrc()
        connectSrc.addDirective(directive: .self)
        
        //style-src
        var styleSrc = StyleSrc()
        styleSrc.addDirective(directive: .self)
        styleSrc.addDirective(directive: .unsafeInline)
        
        //font-src
        var fontSrc = FontSrc()
        fontSrc.addDirective(directive: .self)
        fontSrc.addDirective(directive: .data)
        
        //script-src
        var scriptSrc = ScriptSrc()
        scriptSrc.addDirective(directive: .self)
        
        //img-src
        var imgSrc = ImgSrc()
        imgSrc.addDirective(directive: .self)
        imgSrc.addDirective(directive: .data)
        
        contentSecurityPolicy.add(defaultSrc)
        contentSecurityPolicy.add(connectSrc)
        contentSecurityPolicy.add(styleSrc)
        contentSecurityPolicy.add(fontSrc)
        contentSecurityPolicy.add(scriptSrc)
        contentSecurityPolicy.add(imgSrc)
        
        return contentSecurityPolicy
    }
}
