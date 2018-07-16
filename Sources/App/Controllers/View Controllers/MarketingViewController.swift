import Foundation
import Vapor

class MarketingViewController: RouteCollection {
    func boot(router: Router) throws {
        router.frontend(.noAuthed) { build in
            build.get("/", use: home)
        }
    }
    
    func home(req: Request) throws -> Future<View> {
        return try req.view().render("index", request: req)
    }
}
