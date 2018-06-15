import Vapor
import FluentMySQL

public func migrate(migrations: inout MigrationConfig) throws {
    migrations.add(model: User.self, database: .mysql)
    migrations.add(model: Token.self, database: .mysql)
}
