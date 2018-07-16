import XCTest
import Foundation
import Crypto
@testable import Vapor
@testable import App

class LoginIntegrationTests: XCTestCase {
    var app: Application!
    
    override func setUp() {
        app = try! Application.testable()
    }
    
    func testLinuxTestSuiteIncludesAllTests() {
        #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
        let thisClass = type(of: self)
        let linuxCount = 1
        let darwinCount = Int(thisClass.defaultTestSuite.testCaseCount)
        XCTAssertEqual(linuxCount, darwinCount, "\(darwinCount - linuxCount) tests are missing from allTests")
        #endif
    }
}
