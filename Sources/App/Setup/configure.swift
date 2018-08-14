import FluentMySQL
import Vapor
import Leaf
import Redis
import VaporSecurityHeaders
import URLEncodedForm
import Authentication
import Flash

public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    // MARK: -  Register database providers first
    try services.register(FluentMySQLProvider())
    try services.register(RedisProvider())
    
    // MARK: -  Setup Auth
    try services.register(AuthenticationProvider())
    
    // MARK: -  Register routes to the router
    services.register(Router.self) { _ -> EngineRouter in
        let router = EngineRouter.default()
        try routes(router)
        return router
    }

    // MARK: -  Register the databases
    services.register { container -> DatabasesConfig in
        var databaseConfig = DatabasesConfig()
        try databases(config: &databaseConfig)
        return databaseConfig
    }

    // MARK: -  Register and Prefer Leaf
    try services.register(LeafProvider())
    services.register(ViewRenderer.self) { container in
        return LeafRenderer(config: try container.make(), using: container)
    }
    
    config.prefer(LeafRenderer.self, for: ViewRenderer.self)
    
    // MARK: -  Register Sessions
    let secure = env == .production
    services.register { _ -> SessionsConfig in
        let sessionsConfig = SessionsConfig(cookieName: "vapor-session") { value in
            return HTTPCookieValue(string: value,
                                   expires: Date(timeIntervalSinceNow: 60 * 60 * 24 * 7),
                                   maxAge: nil,
                                   domain: nil,
                                   path: "/",
                                   isSecure: secure,
                                   isHTTPOnly: true,
                                   sameSite: .lax)
        }
        
        return sessionsConfig
    }
    
    services.register(Sessions.self) { container -> KeyedCacheSessions in
        let keyedCache = try container.keyedCache(for: .redis)
        return KeyedCacheSessions(keyedCache: keyedCache)
    }
    
    //MARK: - CSRF
    services.register(CSRF.self) { _ -> CSRFVerifier in
        return CSRFVerifier()
    }
    
    config.prefer(CSRFVerifier.self, for: CSRF.self)
    
    // MARK: -  Per-Request Security Headers
    services.register { _ in
        return CSPRequestConfiguration()
    }
    
    // MARK: -  Register middleware
    services.register { _ in
        return TranseoErrorMiddleware()
    }
    
    services.register { _ -> MiddlewareConfig in
        var middlewares = MiddlewareConfig()
        try middleware(config: &middlewares)
        return middlewares
    }
    
    // MARK: -  Call the migrations
    services.register { container -> MigrationConfig in
        var migrationConfig = MigrationConfig()
        try migrate(migrations: &migrationConfig)
        return migrationConfig
    }
    
    // MARK: -  Register CommonViewContext
    services.register { _ -> CommonViewContext in
        return CommonViewContext()
    }
    
    // MARK: -  Register Content Config
    services.register { container -> ContentConfig in
        var contentConfig = ContentConfig.default()
        try content(config: &contentConfig)
        return contentConfig
    }
    
    // MARK: -  Command Config
    services.register { _ -> CommandConfig in
        var commandConfig = CommandConfig.default()
        commands(config: &commandConfig)
        return commandConfig
    }
    
    // MARK: -  Register KeyStorage
    services.register { container -> KeyStorage in
        guard let apiKey = Environment.get(Constants.restMiddlewareEnvKey) else { throw Abort(.internalServerError) }
        return KeyStorage(restMiddlewareApiKey: apiKey)
    }
    
    // MARK: -  Leaf Tag Config
    services.register { _ in
        return LeafTagConfig.default()
    }
    
    // MARK: - Repository Setup
    setupRepositories(services: &services, config: &config)
}
