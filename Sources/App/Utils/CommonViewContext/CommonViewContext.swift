import Foundation
import Vapor

struct CommonViewContext: Service, Content {
    var userObject: CommonUserObject?
    
    struct CommonUserObject: Content {
        var name: String?
        var email: String?
        var id: Int?
    }
}
