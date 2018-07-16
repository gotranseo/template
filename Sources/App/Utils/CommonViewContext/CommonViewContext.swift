import Foundation
import Vapor
import Flash

struct CommonViewContext: Service, Content {
    var userObject: CommonUserObject?
    var flashes: [Flash]?
    
    struct CommonUserObject: Content {
        var name: String?
        var email: String?
        var id: Int?
    }
}
