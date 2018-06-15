
import Foundation
import Vapor

protocol ViewContextRepresentable {
    var common: CommonViewContext? { get set }
}

typealias ViewContext = ViewContextRepresentable & Encodable
