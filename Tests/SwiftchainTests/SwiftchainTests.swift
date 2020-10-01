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

/// A `class` defining common `Keychain` tests.
final class SwiftchainTests: XCTestCase {
    /// The underlying keychain container.
    let container: Keychain.Container = {
        // Empty out everything before starting.
        try? Keychain.default.empty()
        // Return `Container`.
        return Keychain.default.container(for: "id")
    }()

    /// Test `Keychain` setters and getters for common instance types.
    func testBool() throws {
        // Prepare values.
        let value = true
        // Test.
        try container.store(value)
        XCTAssert(try container.fetch() == value)
        XCTAssert(!container.isEmpty)
    }

    /// Test `Keychain` setters and getters for common instance types.
    func testCGFloat() throws {
        // Prepare values.
        let value: CGFloat = 2.3
        // Test.
        try container.store(value)
        XCTAssert(try container.fetch() == value)
        XCTAssert(!container.isEmpty)
    }

    /// Test `Keychain` setters and getters for common instance types.
    func testCGPoint() throws {
        // Prepare values.
        let value = CGPoint(x: 1.2, y: 3.1)
        // Test.
        try container.store(value)
        XCTAssert(try container.fetch() == value)
        XCTAssert(!container.isEmpty)
    }

    /// Test `Keychain` setters and getters for common instance types.
    func testData() throws {
        // Prepare values.
        let value = "somevalue".data(using: .utf8)!
        // Test.
        try container.store(value)
        XCTAssert(try container.fetch() == value)
        XCTAssert(!container.isEmpty)
    }

    /// Test `Keychain` setters and getters for common instance types.
    func testDouble() throws {
        // Prepare values.
        let value: Double = 2.3
        // Test.
        try container.store(value)
        XCTAssert(try container.fetch() == value)
        XCTAssert(!container.isEmpty)
    }

    /// Test `Keychain` setters and getters for common instance types.
    func testInt() throws {
        // Prepare values.
        let value: Int = 1
        // Test.
        try container.store(value)
        XCTAssert(try container.fetch() == value)
        XCTAssert(!container.isEmpty)
    }

    /// Test `Keychain` setters and getters for common instance types.
    func testFloat() throws {
        // Prepare values.
        let value: Float = 321.6
        // Test.
        try container.store(value)
        XCTAssert(try container.fetch() == value)
        XCTAssert(!container.isEmpty)
    }

    /// Test `Keychain` setters and getters for common instance types.
    func testString() throws {
        // Prepare values.
        let value = "somevalue"
        // Test.
        try container.store(value)
        XCTAssert(try container.fetch() == value)
        XCTAssert(!container.isEmpty)
    }

    /// Test removal.
    func testRemove() throws {
        // Check for all keys.
        XCTAssert(!self.container.isEmpty)
        let keys = try Keychain.default.containers()
        XCTAssert(keys.contains(where: { $0.key == self.container.key }))
        XCTAssert(keys.count == 1)
        // Remove previously set values.
        XCTAssert(!self.container.isEmpty)
        try self.container.empty()
        XCTAssert(self.container.isEmpty)
        // Prepare to remove all.
        let container = Keychain.default.container(for: "two")
        XCTAssert(container.isEmpty)
        try container.store(2)
        XCTAssert(!container.isEmpty)
        let value: Int? = try container.drop()
        XCTAssert(value == 2)
        XCTAssert(container.isEmpty)
    }
}
#endif
