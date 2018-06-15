import FluentMySQL
import Vapor
import Leaf
import Redis
import VaporSecurityHeaders
import URLEncodedForm
import Authentication

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
    var databases = DatabasesConfig()
    databases.add(database: MySQLDatabase(config: mysqlConfig), as: .mysql)
    databases.add(database: redisConfig, as: .redis)
    services.register(databases)

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
    var migrations = MigrationConfig()
    try migrate(migrations: &migrations)
    services.register(migrations)
    
    /// Register CommonViewContext
    let cvc = CommonViewContext()
    services.register(cvc)
    
    /// Register Content Config
    var contentConfig = ContentConfig.default()
    let formDecoder = URLEncodedFormDecoder(omitEmptyValues: true, omitFlags: false)
    contentConfig.use(decoder: formDecoder, for: .urlEncodedForm)
    services.register(contentConfig)
    
    /// Command Config
    var commandConfig = CommandConfig.default()
    commandConfig.useFluentCommands()
    services.register(commandConfig)
    
    /// Register KeyStorage
    guard let apiKey = Environment.get(Constants.restMiddlewareEnvKey) else { throw Abort(.internalServerError) }
    services.register(KeyStorage(restMiddlewareApiKey: apiKey))
}
