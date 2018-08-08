//
//  content.swift
//  App
//
//  Created by Jimmy McDermott on 8/8/18.
//

import Foundation
import Vapor

public func content(config: inout ContentConfig) throws {
    let formDecoder = URLEncodedFormDecoder(omitEmptyValues: true, omitFlags: false)
    config.use(decoder: formDecoder, for: .urlEncodedForm)
}
