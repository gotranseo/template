// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "TranseoTemplate",
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),
        .package(url: "https://github.com/vapor/fluent-mysql.git", from: "3.0.0"),
        .package(url: "https://github.com/vapor/redis.git", from: "3.0.0-rc.2.6"),
        .package(url: "https://github.com/vapor/auth.git", from: "2.0.0-rc.3"),
        .package(url: "https://github.com/gotranseo/flash.git", from: "3.0.1"),
        .package(url: "https://github.com/vapor/url-encoded-form.git", from: "1.0.0"),
        .package(url: "https://github.com/vapor/leaf.git", from: "3.0.0-rc.2"),
        .package(url: "https://github.com/brokenhandsio/VaporSecurityHeaders.git", from: "2.0.0")
    ],
    targets: [
        .target(name: "App", dependencies: ["FluentMySQL", "Vapor", "Redis", "Authentication", "Flash", "URLEncodedForm", "Leaf", "VaporSecurityHeaders"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)
