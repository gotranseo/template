import Foundation

struct CSRFContext: CSRFViewContext, ViewContext {
    var common: CommonViewContext?
    var csrf: String
    
    init(csrf: String) {
        self.csrf = csrf
    }
}
