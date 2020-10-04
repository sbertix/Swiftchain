//
//  SwiftchainTests.swift
//
//
//  Created by Stefano Bertagno on 30/09/20.
//

@testable import Swiftchain

#if os(macOS)
import CoreGraphics
import XCTest

/// A `class` defining common `Keychain` tests.
final class SwiftchainTests: XCTestCase {
    /// The underlying keychain.
    let keychain = Keychain(service: "some.service")
    /// The underlying keychain container.
    var container: Keychain.Container { keychain.container(for: "id") }

    /// Setup testing.
    override func setUpWithError() throws {
        try super.setUpWithError()
        try keychain.empty()
    }

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
        XCTAssert(container.isEmpty)
        try container.store(2)
        XCTAssert(!container.isEmpty)
        // Check for all keys.
        let containers = try keychain.containers()
        XCTAssert(containers.contains(where: { $0.key == container.key }))
        // Remove.
        let value: Int? = try container.drop()
        XCTAssert(value == 2)
        XCTAssert(container.isEmpty)
    }

    /// Test copy.
    func testCopy() throws {
        let start = keychain.container(for: "start")
        let end = keychain.container(for: "end")
        // Copy the item.
        try start.store(1)
        try start.copy(to: end)
        XCTAssert(try start.fetch(Int.self) == end.fetch(Int.self))
        // Move the item.
        try start.store(2)
        try start.move(to: end)
        XCTAssert(try end.fetch(Int.self) == 2)
        XCTAssert(start.isEmpty)
    }
}
#endif
