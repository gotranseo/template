import Vapor
import TemplateKit
import Leaf
@testable import App

class CapturingViewProvider: Provider {
    func register(_ services: inout Services) throws {
        services.register(ViewRenderer.self) { container -> CapturingViewRenderer in
            return CapturingViewRenderer()
        }
    }
    
    func didBoot(_ container: Container) throws -> EventLoopFuture<Void> {
        return .done(on: container)
    }
}

class CapturingViewRenderer: ViewRenderer, Service {
    var shouldCache: Bool = true
    static var capturedContext: ViewContext?
    
    func render<E>(_ path: String, _ context: E, userInfo: [AnyHashable : Any]) -> EventLoopFuture<View> where E : Encodable {
        CapturingViewRenderer.capturedContext = context as? ViewContext
        return Future.map(on: EmbeddedEventLoop()) { View(data: "".convertToData()) }
    }
    
    init() { }
}

extension Application {
    func capturingViewRenderer() -> CapturingViewRenderer {
        return try! make()
    }
}
