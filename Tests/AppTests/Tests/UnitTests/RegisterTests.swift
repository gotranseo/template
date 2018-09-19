import XCTest
import Foundation
import Crypto
@testable import Vapor
@testable import App

class RegisterTests: XCTestCase {
    var app: Application!
    
    override func setUp() {
        app = try! Application.testable()
    }
    
    func testLinuxTestSuiteIncludesAllTests() {
        #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
        let thisClass = type(of: self)
        let linuxCount = thisClass.__allTests.count
        let darwinCount = Int(thisClass.defaultTestSuite.testCaseCount)
        XCTAssertEqual(linuxCount, darwinCount, "\(darwinCount - linuxCount) tests are missing from allTests")
        #endif
    }
    
    /// Tests that an email cannot be registered twice
    func testRegisterEmailAlreadyExists() throws {
        let registerRequest = RegisterRequest(email: "email@email.com", name: "name", password: "password", confirmPassword: "password", csrf: "")
        
        let registerResponse = try app.sendRequest(to: "/register", method: .POST, data: registerRequest, contentType: .json)
        XCTAssertEqual(registerResponse.http.status, .seeOther)
        XCTAssertEqual(registerResponse.http.headers.firstValue(name: .location), "/register")
    }
    
    /// Tests that an invalid email cannot register
    func testInvalidEmailFails() throws {
        let registerRequest = RegisterRequest(email: "not an email", name: "name", password: "password", confirmPassword: "password", csrf: "")
        
        let registerResponse = try app.sendRequest(to: "/register", method: .POST, data: registerRequest, contentType: .json)
        XCTAssertEqual(registerResponse.http.status, .seeOther)
        XCTAssertEqual(registerResponse.http.headers.firstValue(name: .location), "/register")
    }
    
    /// Tests that passwords must match
    func testRegisterPasswordsDontMatch() throws {
        let registerRequest = RegisterRequest(email: "email@email.com", name: "name", password: "password1", confirmPassword: "password2", csrf: "")
        
        let registerResponse = try app.sendRequest(to: "/register", method: .POST, data: registerRequest, contentType: .json)
        XCTAssertEqual(registerResponse.http.status, .seeOther)
        XCTAssertEqual(registerResponse.http.headers.firstValue(name: .location), "/register")
    }
    
    /// Tests that users can register successfully when meeting validation requirements
    func testSuccessfulRegister() throws {
        let registerRequest = RegisterRequest(email: "email2@email.com", name: "name", password: "password", confirmPassword: "password", csrf: "")
        
        let registerResponse = try app.sendRequest(to: "/register", method: .POST, data: registerRequest, contentType: .json)
        XCTAssertEqual(registerResponse.http.status, .seeOther)
        XCTAssertEqual(registerResponse.http.headers.firstValue(name: .location), "/home")
    }
}
