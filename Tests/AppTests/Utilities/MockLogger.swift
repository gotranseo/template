//
//  MockLogger.swift
//  AppTests
//
//  Created by Jimmy McDermott on 5/7/18.
//

import Foundation
import Vapor

struct MockLogger: Logger, Service {
    func log(_ string: String, at level: LogLevel, file: String, function: String, line: UInt, column: UInt) {

    }
}
