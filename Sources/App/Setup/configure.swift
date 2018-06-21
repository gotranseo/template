import FluentMySQL
import Vapor
import Leaf
import Redis
import VaporSecurityHeaders
import URLEncodedForm
import Authentication
import Flash

public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    /// Register providers first
    try services.register(FluentMySQLProvider())
    
    guard let databaseUrlString = Environment.get(Constants.databaseURL) else { throw Abort(.internalServerError) }
    guard let mysqlConfig = try MySQLDatabaseConfig(url: databaseUrlString) else { throw Abort(.internalServerError) }

    /// Setup Auth
    try services.register(AuthenticationProvider())
    
    /// Setup Redis
    guard let redisUrlString = Environment.get(Constants.redisURL) else { throw Abort(.internalServerError) }
    guard let redisUrl = URL(string: redisUrlString) else { throw Abort(.internalServerError) }
    
    /// Register Redis
    try services.register(RedisProvider())
    let redisConfig = try RedisDatabase(config: RedisClientConfig(url: redisUrl))
    
    /// Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    /// Register the databases
    services.register { container -> DatabasesConfig in
        var databaseConfig = DatabasesConfig()
        databaseConfig.add(database: MySQLDatabase(config: mysqlConfig), as: .mysql)
        databaseConfig.add(database: redisConfig, as: .redis)
        return databaseConfig
    }

    /// Register and Prefer Leaf
    try services.register(LeafProvider())
    services.register(ViewRenderer.self) { container in
        return LeafRenderer(config: try container.make(), using: container)
    }
    
    config.prefer(LeafRenderer.self, for: ViewRenderer.self)
    
    /// Register Sessions
    let secure = env == .production
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
    
    services.register(sessionsConfig)
    
    services.register(Sessions.self) { container -> KeyedCacheSessions in
        let keyedCache = try container.keyedCache(for: .redis)
        return KeyedCacheSessions(keyedCache: keyedCache)
    }
    
    services.register(CSRF.self) { _ -> CSRFVerifier in
        return CSRFVerifier()
    }
    
    config.prefer(CSRFVerifier.self, for: CSRF.self)
    
    /// Setup Security Headers
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
    
    /// Per-Request Security Headers
    services.register { _ in
        return CSPRequestConfiguration()
    }
    
    /// Register middleware
    services.register(TranseoErrorMiddleware())
    
    var middlewares = MiddlewareConfig()
    middlewares.use(securityHeadersMiddleware)
    middlewares.use(FileMiddleware.self)
    middlewares.use(TranseoErrorMiddleware.self)
    middlewares.use(SessionsMiddleware.self)
    services.register(middlewares)
    
    /// Call the migrations
    services.register { container -> MigrationConfig in
        var migrationConfig = MigrationConfig()
        try migrate(migrations: &migrationConfig)
        return migrationConfig
    }
    
    /// Register CommonViewContext
    let cvc = CommonViewContext()
    services.register(cvc)
    
    /// Register Content Config
    services.register { container -> ContentConfig in
        var contentConfig = ContentConfig.default()
        let formDecoder = URLEncodedFormDecoder(omitEmptyValues: true, omitFlags: false)
        contentConfig.use(decoder: formDecoder, for: .urlEncodedForm)
        return contentConfig
    }
    
    /// Command Config
    var commandConfig = CommandConfig.default()
    commandConfig.useFluentCommands()
    services.register(commandConfig)
    
    /// Register KeyStorage
    guard let apiKey = Environment.get(Constants.restMiddlewareEnvKey) else { throw Abort(.internalServerError) }
    services.register(KeyStorage(restMiddlewareApiKey: apiKey))
    
    //Leaf Tag Config
    var defaultTags = LeafTagConfig.default()
    defaultTags.use(FlashTag(), as: "flash")
    
    services.register(defaultTags)
    
    /// Flash Provider
    try services.register(FlashProvider())
}
