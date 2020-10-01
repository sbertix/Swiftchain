//
//  SwiftchainAuthenticationTests.swift
//  
//
//  Created by Stefano Bertagno on 01/10/20.
//

@testable import Swiftchain

import CoreGraphics
import XCTest

/// A `class` defining common `Keychain.Authentication` tests.
final class SwiftchainAuthenticationTests: XCTestCase {
    /// Test some authentication combinations.
    func testOr() {
        // Obtain set.
        var set: Keychain.Authentication = []
        if #available(macOS 10.11, *) { set.insert(.devicePasscode) }
        if #available(iOS 11.3, macOS 10.13.4, tvOS 11.3, watchOS 4.3, *) {
            set.insert(.biometryAny)
            set.insert(.biometryCurrentSet)
        }
        if #available(macOS 10.11, *) { set.insert(.userPresence) }
        #if os(macOS)
        if #available(macOS 10.15, *) { set.insert(.watch) }
        #endif
        if #available(macOS 10.12.1, *) { set = set.or() }
        // Obtain flags.
        var flags: SecAccessControlCreateFlags = []
        if #available(macOS 10.11, *) { flags.insert(.devicePasscode) }
        if #available(iOS 11.3, macOS 10.13.4, tvOS 11.3, watchOS 4.3, *) {
            flags.insert(.biometryAny)
            flags.insert(.biometryCurrentSet)
        }
        if #available(macOS 10.12.1, *) { flags.insert(.or) }
        #if os(macOS)
        if #available(macOS 10.15, *) { flags.insert(.watch) }
        #endif
        // Check equality.
        XCTAssert(set.flags == flags)
    }

    /// Test some authentication combinations.
    func testAnd() {
        // Obtain set.
        var set: Keychain.Authentication = []
        if #available(macOS 10.11, *) { set.insert(.devicePasscode) }
        if #available(iOS 11.3, macOS 10.13.4, tvOS 11.3, watchOS 4.3, *) {
            set.insert(.biometryAny)
            set.insert(.biometryCurrentSet)
        }
        if #available(macOS 10.11, *) { set.insert(.userPresence) }
        #if os(macOS)
        if #available(macOS 10.15, *) { set.insert(.watch) }
        #endif
        if #available(macOS 10.12.1, *) { set = set.and() }
        // Obtain flags.
        var flags: SecAccessControlCreateFlags = []
        if #available(macOS 10.11, *) { flags.insert(.devicePasscode) }
        if #available(iOS 11.3, macOS 10.13.4, tvOS 11.3, watchOS 4.3, *) {
            flags.insert(.biometryAny)
            flags.insert(.biometryCurrentSet)
        }
        if #available(macOS 10.12.1, *) { flags.insert(.and) }
        #if os(macOS)
        if #available(macOS 10.15, *) { flags.insert(.watch) }
        #endif
        // Check equality.
        XCTAssert(set.flags == flags)
    }
}
