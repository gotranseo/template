import XCTest
import Foundation
import FluentMySQL
import Crypto
@testable import Vapor
@testable import App

class LoginTests: XCTestCase {
    var app: Application!
    var conn: MySQLConnection!
    
    override func setUp() {
        try! Application.reset()
        
        app = try! Application.testable()
        conn = try! app.newConnection(to: .mysql).wait()
    }
    
    override func tearDown() {
        conn.close()
    }
    
    func testLinuxTestSuiteIncludesAllTests() {
        #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
        let thisClass = type(of: self)
        let linuxCount = thisClass.__allTests.count
        let darwinCount = Int(thisClass.defaultTestSuite.testCaseCount)
        XCTAssertEqual(linuxCount, darwinCount, "\(darwinCount - linuxCount) tests are missing from allTests")
        #endif
    }
    
    /// Tests that a user with invalid credentials cannot login
    func testLoginInvalidCredentials() throws {
        let _ = try User(name: "name", email: "email@email.com", password: try BCrypt.hash("password")).save(on: conn).wait()
        let loginRequest = LoginRequest(email: "email@email.com", password: "wrong password", csrf: "n/a")
        
        let loginResponse = try app.sendRequest(to: "/login", method: .POST, data: loginRequest, contentType: .json)
        XCTAssertEqual(loginResponse.http.headers.firstValue(name: .location), "/login")
    }
    
    /// Tests that a user with valid credentials can login
    func testLoginSuccessful() throws {
        
    }
}
