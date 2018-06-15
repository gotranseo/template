import XCTest
import Foundation
import FluentMySQL
@testable import Vapor
@testable import App

class RegisterTests: XCTestCase {
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
        //        let linuxCount = thisClass.__allTests.count
        let linuxCount = 0
        let darwinCount = Int(thisClass.defaultTestSuite.testCaseCount)
        XCTAssertEqual(linuxCount, darwinCount, "\(darwinCount - linuxCount) tests are missing from allTests")
        #endif
    }
}
