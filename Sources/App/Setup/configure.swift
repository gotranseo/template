import FluentMySQL
import Vapor
import SendGrid

public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    /// Register providers first
    try services.register(FluentMySQLProvider())
    
    guard let databaseUrlString = Environment.get(Constants.databaseURL) else { throw Abort(.internalServerError) }
    guard let databaseUrl = URL(string: databaseUrlString) else { throw Abort(.badRequest) }
    guard let host = databaseUrl.host else { throw Abort(.badRequest) }
    guard let port = databaseUrl.port else { throw Abort(.badRequest) }
    guard let username = databaseUrl.user else { throw Abort(.badRequest) }
    guard let password = databaseUrl.password else { throw Abort(.badRequest) }
    guard let databaseName = databaseUrl.databaseName else { throw Abort(.badRequest) }
    
    let mysqlConfig = MySQLDatabaseConfig(hostname: host,
                                          port: port,
                                          username: username,
                                          password: password,
                                          database: databaseName)
    services.register(mysqlConfig)

    /// Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    /// Register middleware
    var middlewares = MiddlewareConfig()
    middlewares.use(ErrorMiddleware.self)
    services.register(middlewares)

    /// Register the databases
    var databases = DatabasesConfig()
    databases.add(database: MySQLDatabase(config: mysqlConfig), as: .mysql)
    services.register(databases)

    /// Call the migrations
    var migrations = MigrationConfig()
    try migrate(migrations: &migrations)
    services.register(migrations)
    
    /// Command Config
    var commandConfig = CommandConfig.default()
    commandConfig.useFluentCommands()
    services.register(commandConfig)
    
    /// Register KeyStorage
    guard let apiKey = Environment.get(Constants.restMiddlewareEnvKey) else { throw Abort(.internalServerError) }
    services.register(KeyStorage(restMiddlewareApiKey: apiKey))
}
