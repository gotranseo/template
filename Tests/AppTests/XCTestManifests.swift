import XCTest

extension LoginIntegrationTests {
    static let __allTests = [
        ("testLinuxTestSuiteIncludesAllTests", testLinuxTestSuiteIncludesAllTests)
    ]
}

extension RegisterIntegrationTests {
    static let __allTests = [
        ("testLinuxTestSuiteIncludesAllTests", testLinuxTestSuiteIncludesAllTests)
    ]
}

extension UserRepositoryTests {
    static let __allTests = [
        ("testLinuxTestSuiteIncludesAllTests", testLinuxTestSuiteIncludesAllTests)
    ]
}

extension LoginTests {
    static let __allTests = [
        ("testLinuxTestSuiteIncludesAllTests", testLinuxTestSuiteIncludesAllTests),
        ("testLoginInvalidCredentials", testLoginInvalidCredentials),
        ("testLoginSuccessful", testLoginSuccessful),
    ]
}

extension RegisterTests {
    static let __allTests = [
        ("testLinuxTestSuiteIncludesAllTests", testLinuxTestSuiteIncludesAllTests),
        ("testInvalidEmailFails", testInvalidEmailFails),
        ("testRegisterEmailAlreadyExists", testRegisterEmailAlreadyExists),
        ("testRegisterPasswordsDontMatch", testRegisterPasswordsDontMatch),
        ("testSuccessfulRegister", testSuccessfulRegister),
    ]
}

#if !os(macOS)
public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(LoginTests.__allTests),
        testCase(RegisterTests.__allTests),
    ]
}
#endif
