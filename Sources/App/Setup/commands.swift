//
//  commands.swift
//  App
//
//  Created by Jimmy McDermott on 8/8/18.
//

import Foundation
import Vapor

public func commands(config: inout CommandConfig) {
    config.useFluentCommands()
}
