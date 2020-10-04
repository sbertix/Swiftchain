//
//  SecurityConstants.swift
//  
//
//  Created by Stefano Bertagno on 30/09/20.
//

import Foundation

/// A `struct` holding reference to all `CFString` identifiers.
struct SecurityConstants: OptionSet {
    /// The underlying value.
    let rawValue: Int

    // MARK: Container

    /// The `Container`'s `key`.
    static let key = SecurityConstants(rawValue: 1 << 0)
    /// The `Container`'s underlying data value.
    static let value = SecurityConstants(rawValue: 1 << 1)

    // MARK: Keychain

    /// The `Keychain`'s service name.
    static let service = SecurityConstants(rawValue: 1 << 4)
    /// The `Keychain`'s access group.
    static let group = SecurityConstants(rawValue: 1 << 5)
    /// The `Keychain`'s accessibility.
    static let accessibility = SecurityConstants(rawValue: 1 << 6)
    /// The `Keychain`'s access control.
    static let authentication = SecurityConstants(rawValue: 1 << 7)
    /// The `Keychain`'s synchronization option.
    static let synchronization = SecurityConstants(rawValue: 1 << 8)

    /// Keychain.
    static let keychain: SecurityConstants = [.service, .group, .synchronization]

    // MARK: Request

    /// Search one item.
    static let one = SecurityConstants(rawValue: 1 << 10)
    /// Search all items.
    static let all = SecurityConstants(rawValue: 1 << 11)
    /// Return attributes.
    static let attributes = SecurityConstants(rawValue: 1 << 12)
    /// Return data.
    static let data = SecurityConstants(rawValue: 1 << 13)

    // MARK: Query

    /// Prepare a query.
    ///
    /// - returns: A dictionary.
    func query() -> [CFString: Any] {
        // Prepare the query.
        var query: [CFString: Any] = [kSecClass: kSecClassGenericPassword]
        if contains(.one) {
            query[kSecMatchLimit] = kSecMatchLimitOne
        } else if contains(.all) {
            query[kSecMatchLimit] = kSecMatchLimitAll
        }
        if contains(.attributes) { query[kSecReturnAttributes] = kCFBooleanTrue! }
        if contains(.data) { query[kSecReturnData] = kCFBooleanTrue! }
        // Return query.
        return query
    }

    /// Prepare a query dictionary.
    ///
    /// - parameter keychain: A valid `Keychain`.
    /// - throws: Some `CFError`.
    /// - returns: A dictionary.
    func query(for keychain: Keychain) throws -> [CFString: Any] {
        // Prepare the query.
        var query = self.query()
        if let service = keychain.service, contains(.service) { query[kSecAttrService] = service as CFString }
        if let group = keychain.group, contains(.group) { query[kSecAttrAccessGroup] = group as CFString }
        if keychain.authentication.isEmpty, contains(.accessibility) { query[kSecAttrAccessible] = keychain.accessibility.rawValue }
        if !keychain.authentication.isEmpty, contains(.authentication) {
            var error: Unmanaged<CFError>?
            query[kSecAttrAccessControl] = withUnsafeMutablePointer(to: &error) {
                SecAccessControlCreateWithFlags(nil,
                                                keychain.accessibility.rawValue,
                                                keychain.authentication.flags,
                                                $0)
            }
            // Crash on `Error`.
            if let error = error?.takeUnretainedValue() { throw error }
        }
        if keychain.isSynchronizable, contains(.synchronization) { query[kSecAttrSynchronizable] = kSecAttrSynchronizableAny }
        // Return query.
        return query
    }

    /// Prepare a query dictionary.
    ///
    /// - parameters:
    ///     - container: A valid `Keychain.Container`.
    ///     - value: An optional `Data`. Defaults to `nil`.
    /// - throws: Some `CFError`.
    /// - returns: A dictionary.
    func query(for container: Keychain.Container, with value: Data? = nil) throws -> [CFString: Any] {
        // Prepare the query.
        var query = try self.query(for: container.keychain)
        if contains(.key) { query[kSecAttrAccount] = container.key }
        if let value = value, contains(.value) {
            query[kSecValueData] = value as CFData
            if query[kSecAttrSynchronizable] != nil { query[kSecAttrSynchronizable] = kCFBooleanTrue! }
        }
        // Return query.
        return query
    }
}
