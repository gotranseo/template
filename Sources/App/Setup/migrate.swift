import Vapor
import FluentMySQL
import TranseoCommon

public func migrate(migrations: inout MigrationConfig) throws {
    migrations.add(model: User.self, database: .mysql)
    migrations.add(model: Token.self, database: .mysql)
}
