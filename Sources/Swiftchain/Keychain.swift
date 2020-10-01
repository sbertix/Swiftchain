//
//  Keychain.swift
//  
//
//  Created by Stefano Bertagno on 30/09/20.
//

import Foundation

/// A `class` defining a wrapper for all common keychain operations.
open class Keychain {
    /// A shared instance of `Keychain`.
    public static var `default` = Keychain()

    /// A shared lock.
    private static let lock = NSLock()

    /// The underlying service name. Defaults to the bundle identifier or `"Swiftchain"`, if `nil`.
    public let service: String

    /// The underlying access group. Defaults to `nil`.
    public let group: String?

    /// The underlying accessibility preference. Defaults to `.afterFirstUnlock`.
    ///
    /// - note: Visit https://developer.apple.com/documentation/security/keychain_services/keychain_items/restricting_keychain_item_accessibility
    ///         to learn more about _accessibility_, and its relation to _authentication_..
    public let accessibility: Accessibility

    /// An optional underlying authentication preference. Defaults to empty.
    ///
    /// - note: Visit https://developer.apple.com/documentation/security/keychain_services/keychain_items/restricting_keychain_item_accessibility
    ///         to learn more about _authentication_, and its relation to _accessibility_..
    public let authentication: Authentication

    /// The underlying synchronization preference. Defaults to `false`.
    public let isSynchronizable: Bool

    /// Init.
    ///
    /// - parameters:
    ///     - service: A valid `String` representing the service name for the keychain. Defaults to the bundle identifier or `"Swiftchain"`, if `nil`.
    ///     - group: An optional `String` defining a custom access group, allowing items to be shared among apps. Defaults to `nil`.
    ///     - accessibility: Some valid `Accessibility`. Defaults to `.whenUnlocked`.
    ///     - authentication: Some optional `Authentication`. Defaults to `nil`.
    ///     - isSynchronizable: A valid `Bool` defining whether items should be stored on iCloud or not. Defaults to `false`.
    public required init(service: String = Bundle.main.bundleIdentifier ?? "Swiftchain",
                         group: String? = nil,
                         accessibility: Accessibility = .whenUnlocked,
                         authentication: Authentication = [],
                         isSynchronizable: Bool = false) {
        self.service = service
        self.group = group
        self.accessibility = accessibility
        self.authentication = authentication
        self.isSynchronizable = isSynchronizable
    }

    /// Get the container for a given `id`.
    ///
    /// - parameter key: Some valid `String`.
    /// - returns: A `Keychain.Container` with the given `key`.
    public func container(for key: String) -> Container {
        return .init(keychain: self, key: key)
    }

    /// Empty all containers.
    ///
    /// - throws: Some `Keychain.Error`.
    public func empty() throws {
        // Prepare query.
        var query: [CFString: Any] = [SecurityConstants.class: kSecClassGenericPassword]
        query[SecurityConstants.service] = service
        query[SecurityConstants.accessGroup] = group
        // Remove items.
        switch Keychain.locking({ SecItemDelete(query as CFDictionary) }) {
        case errSecSuccess, errSecItemNotFound: break
        case let status: throw Error.status(status)
        }
    }

    /// Fetch all available keys.
    ///
    /// - throws: Some `Keychain.Error`.
    /// - returns: A set of `String`s.
    public func keys() throws -> Set<String> {
        // Prepare the query.
        var query: [CFString: Any] = [
            SecurityConstants.class: kSecClassGenericPassword,
            SecurityConstants.service: service,
            SecurityConstants.attributes: kCFBooleanTrue!,
            SecurityConstants.matchLimit: kSecMatchLimitAll
        ]
        query[SecurityConstants.accessGroup] = group
        // Fetch results.
        var result: AnyObject?
        switch Keychain.locking({ withUnsafeMutablePointer(to: &result) { SecItemCopyMatching(query as CFDictionary, $0) }}) {
        case errSecSuccess: break
        case errSecItemNotFound: return []
        case let status: throw Error.status(status)
        }
        guard let results = result as? [[AnyHashable: Any]] else { throw Error.invalidCasting }
        // Return results.
        return results.reduce(into: Set<String>()) { set, attributes in
            guard let key = attributes[SecurityConstants.account] as? String else { return }
            set.insert(key as String)
        }
    }

    /// Fetch all available containers.
    ///
    /// - throws: Some `Keychain.Error`.
    /// - returns: An array of `Container`s.
    public func containers() throws -> [Container] {
        return try keys().map(container)
    }

    /// Lock block results.
    ///
    /// - parameter block: A valid block.
    /// - throws: `rethrows` `block`.
    /// - returns: `block` return value.
    static func locking<T>(_ block: () throws -> T) rethrows -> T {
        defer { lock.unlock() }
        lock.lock()
        return try block()
    }
}
