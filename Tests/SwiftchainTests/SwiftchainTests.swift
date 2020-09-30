//
//  SwiftchainTests.swift
//
//
//  Created by Stefano Bertagno on 30/09/20.
//

#if os(macOS)
import CoreGraphics
@testable import Swiftchain
import XCTest

/// An `extension` for `CGPoint`.
extension CGPoint: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }
}

/// A `class` defining common `Keychain` tests.
final class SwiftchainTests: XCTestCase {
    /// A valid `String`.
    let key = "key"

    /// Remove all.
    override class func setUp() {
        super.setUp()
        try? Keychain.default.removeAll()
    }

    /// Test `Keychain` setters and getters for common instance types.
    func testBool() {
        // Prepare values.
        let value = true
        // Test.
        try? Keychain.default.set(value, forKey: key)
        XCTAssert((try? Keychain.default.get(forKey: key)) == value)
    }

    /// Test `Keychain` setters and getters for common instance types.
    func testCGFloat() {
        // Prepare values.
        let value: CGFloat = 2.3
        // Test.
        try? Keychain.default.set(value, forKey: key)
        XCTAssert((try? Keychain.default.get(forKey: key)) == value)
    }

    /// Test `Keychain` setters and getters for common instance types.
    func testCGPoint() {
        // Prepare values.
        let value = CGPoint(x: 1.2, y: 3.1)
        // Test.
        try? Keychain.default.set(value, forKey: key)
        XCTAssert((try? Keychain.default.get(forKey: key)) == value)
    }

    /// Test `Keychain` setters and getters for common instance types.
    func testData() {
        // Prepare values.
        let value = "somevalue".data(using: .utf8)!
        // Test.
        try? Keychain.default.set(value, forKey: key)
        XCTAssert((try? Keychain.default.get(forKey: key)) == value)
    }

    /// Test `Keychain` setters and getters for common instance types.
    func testDouble() {
        // Prepare values.
        let value: Double = 2.3
        // Test.
        try? Keychain.default.set(value, forKey: key)
        XCTAssert((try? Keychain.default.get(forKey: key)) == value)
    }

    /// Test `Keychain` setters and getters for common instance types.
    func testInt() {
        // Prepare values.
        let value: Int = 1
        // Test.
        try? Keychain.default.set(value, forKey: key)
        XCTAssert((try? Keychain.default.get(forKey: key)) == value)
    }

    /// Test `Keychain` setters and getters for common instance types.
    func testFloat() {
        // Prepare values.
        let value: Float = 321.6
        // Test.
        try? Keychain.default.set(value, forKey: key)
        XCTAssert((try? Keychain.default.get(forKey: key)) == value)
    }

    /// Test `Keychain` setters and getters for common instance types.
    func testString() {
        // Prepare values.
        let value = "somevalue"
        // Test.
        try? Keychain.default.set(value, forKey: key)
        XCTAssert((try? Keychain.default.get(forKey: key)) == value)
    }

    /// Test removal.
    func testRemove() {
        // Check for all keys.
        let keys = (try? Keychain.default.allKeys()) ?? []
        XCTAssert(keys.contains(key))
        XCTAssert(keys.count == 1)
        // Remove previously set values.
        XCTAssert(Keychain.default.contains(key: key))
        try? Keychain.default.remove(matchingKey: key)
        XCTAssert(!Keychain.default.contains(key: key))
        // Prepare to remove all.
        try? Keychain.default.set(2, forKey: "two")
        XCTAssert(Keychain.default.contains(key: "two"))
        try? Keychain.default.removeAll()
        XCTAssert(!Keychain.default.contains(key: key))
    }
}
#endif
