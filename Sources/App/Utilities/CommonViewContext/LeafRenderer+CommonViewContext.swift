import Foundation
import Vapor
import Leaf
import Flash

extension ViewRenderer {
    func render<V>(_ path: String, _ context: V, request: Request) throws -> Future<View> where V: ViewContext {
        var commonViewContext = try request.make(CommonViewContext.self)
        try finishCommonContext(request: request, cvc: &commonViewContext)
        
        var finalContext = context
        finalContext.common = commonViewContext
        
        return render(path, finalContext)
    }
    
    func render(_ path: String, request: Request) throws -> Future<View> {
        var commonViewContext = try request.make(CommonViewContext.self)
        try finishCommonContext(request: request, cvc: &commonViewContext)
        
        return render(path, NoContextCommonViewContext(common: commonViewContext))
    }
    
    private func finishCommonContext(request: Request, cvc: inout CommonViewContext) throws {
        let session = try request.session()
        
        if let flashes = session["_flash"], let flashData = flashes.data(using: .utf8) {
            let jsonDecoder = JSONDecoder()
            let decodedData = try jsonDecoder.decode(Flash.self, from: flashData)
            cvc.flash = decodedData
            session["_flash"] = nil
        }
        
        var userId: Int?
        
        if let userIdString = session[Constants.SessionKeys.userId] {
            userId = Int(userIdString)
        }
        
        
        cvc.userObject = CommonViewContext.CommonUserObject(name: session[Constants.SessionKeys.userName],
                                                            email: session[Constants.SessionKeys.userEmail],
                                                            id: userId)
    }
}

struct NoContextCommonViewContext: ViewContext {
    var common: CommonViewContext?
}

struct ErrorViewContext: ViewContext {
    var common: CommonViewContext?
    var error: String
    
    init(error: String) {
        self.error = error
    }
}
