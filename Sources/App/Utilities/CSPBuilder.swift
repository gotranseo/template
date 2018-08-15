//
//  CSPBuilder.swift
//  App
//
//  Created by Jimmy McDermott on 6/11/18.
//

import Foundation

class CSPBuilder {
    private var cspObjects = [ContentSecurityPolicyRepresentable]()
    
    init(cspObjects: [ContentSecurityPolicyRepresentable]) {
        self.cspObjects = cspObjects
    }
    
    init() { }
    
    func add(_ cspPolicy: ContentSecurityPolicyRepresentable) {
        cspObjects.append(cspPolicy)
    }
    
    func generateString() -> String {
        var string = cspObjects.map { $0.finalCSPString() }.joined(separator: "")
        string.removeLast()
        
        return string
    }
}

protocol ContentSecurityPolicyRepresentable {
    var identifier: String { get set }
    var cspString: String { get set }
    mutating func addDirective(directive: String)
    mutating func addDirective(directive: CSPDirectiveType)
    func finalCSPString() -> String
}

enum CSPDirectiveType: String {
    case `self` = "self"
    case data = "data:"
    case unsafeInline = "unsafe-inline"
    
    var shouldHaveSingleQuotes: Bool {
        switch self {
        case .self, .unsafeInline:
            return true
        default:
            return false
        }
    }
}

extension ContentSecurityPolicyRepresentable {
    mutating func addDirective(directive: String) {
        cspString += " \(directive)"
    }
    
    mutating func addDirective(directive: CSPDirectiveType) {
        if directive.shouldHaveSingleQuotes {
            addDirective(directive: "'\(directive.rawValue)'")
        } else {
            addDirective(directive: "\(directive.rawValue)")
        }
    }
    
    func finalCSPString() -> String {
        return "\(identifier)\(cspString); "
    }
}

class DefaultSrc: ContentSecurityPolicyRepresentable {
    var identifier = "default-src"
    var cspString = ""
}

class ConnectSrc: ContentSecurityPolicyRepresentable {
    var identifier = "connect-src"
    var cspString = ""
}

class FontSrc: ContentSecurityPolicyRepresentable {
    var identifier = "font-src"
    var cspString = ""
}

class ScriptSrc: ContentSecurityPolicyRepresentable {
    var identifier = "script-src"
    var cspString = ""
}

class ImgSrc: ContentSecurityPolicyRepresentable {
    var identifier = "img-src"
    var cspString = ""
}

class StyleSrc: ContentSecurityPolicyRepresentable {
    var identifier = "style-src"
    var cspString = ""
}

class FrameSrc: ContentSecurityPolicyRepresentable {
    var identifier = "frame-src"
    var cspString = ""
}

class ReportURI: ContentSecurityPolicyRepresentable {
    var identifier = "report-uri"
    var cspString = ""
}

class ReportTo: ContentSecurityPolicyRepresentable {
    var identifier = "report-to"
    var cspString = ""
}
