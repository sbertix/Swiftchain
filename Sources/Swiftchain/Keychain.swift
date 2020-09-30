//
//  Keychain.swift
//  
//
//  Created by Stefano Bertagno on 30/09/20.
//

#if canImport(CoreGraphics)
import CoreGraphics
#endif

import Foundation

/// A `class` defining a wrapper for all common keychain operations.
open class Keychain {
    /// A shared instance of `Keychain`.
    public static let `default` = Keychain()

    /// The underlying service name. Defaults to the bundle identifier or `"Swiftchain"`, if `nil`.
    public let service: String
    /// The underlying access group. Defaults to `nil`.
    public let group: String?
    /// The underlying accessibility preference. Defaults to `.afterFirstUnlock`.
    public let accessibility: Accessibility
    /// The underlying synchronization preference. Defaults to `false`.
    public let isSynchronizable: Bool

    // MARK: Lifecycle

    /// Init.
    ///
    /// - parameters:
    ///     - service: A valid `String` representing the service name for the keychain. Defaults to the bundle identifier or `"Swiftchain"`, if `nil`.
    ///     - group: An optional `String` defining a custom access group, allowing items to be shared among apps. Defaults to `nil`.
    ///     - accessibility: Some valid `Accessibility`. Defaults to `.whenUnlocked`.
    ///     - isSynchronizable: A valid `Bool` defining whether items should be stored on iCloud or not. Defaults to `false`.
    public required init(service: String = Bundle.main.bundleIdentifier ?? "Swiftchain",
                         group: String? = nil,
                         accessibility: Accessibility = .whenUnlocked,
                         isSynchronizable: Bool = false) {
        self.service = service
        self.group = group
        self.accessibility = accessibility
        self.isSynchronizable = isSynchronizable
    }

    // MARK: Getters

    /// Return all stored keys.
    ///
    /// - throws: An instance of `KeychainWrapper.Error`.
    /// - returns: A set of `String`s.
    open func allKeys() throws -> Set<String> {
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
        switch SecItemCopyMatching(query as CFDictionary, &result) {
        case errSecSuccess, errSecItemNotFound: break
        case let status: throw Error.status(status)
        }
        guard let results = result as? [[AnyHashable: Any]] else { throw Error.invalidCasting }
        // Return results.
        return results.reduce(into: Set<String>()) { set, attributes in
            guard let data = (attributes[SecurityConstants.generic] as? Data)
                    ?? (attributes[SecurityConstants.account] as? Data),
                  let key = String(data: data, encoding: .utf8) else { return }
            set.insert(key)
        }
    }

    /// Returns a stored object for a specified `key`.
    ///
    /// Use this when the return type is **ambiguous**.
    /// ```swift
    /// let integer = try? Keychain.default.get(Int.self, key: "some-key")
    /// ```
    ///
    /// - parameters:
    ///     - type: Some type.
    ///     - key: A valid `String`.
    ///     - accessibility: An optional instance of `Accessibility`. Defaults to `nil`, meaning `self.accessibility` will be used.
    ///     - isSynchronizable: An optional `Bool`. Defaults to `nil`, meaning `self.isSynchronizable` will be used.
    /// - throws: An instance of `KeychainWrapper.Error` or a `Swift.Error`.
    /// - returns: The persisted object if found, `nil` otherwise.
    open func get<T>(_ type: T.Type,
                     forKey key: String,
                     accessible accessibility: Accessibility? = nil,
                     isSynchronizable: Bool? = nil) throws -> T? {
        // Downcast or throw.
        func downcast<S>(_ value: S?) throws -> T? {
            guard let value = value else { return nil }
            guard let result = value as? T else { throw Error.invalidCasting }
            return result
        }

        // Prepare the query.
        var query = Keychain.query(forKey: key,
                                   service: service,
                                   group: group,
                                   accessible: accessibility ?? self.accessibility,
                                   isSynchronizable: isSynchronizable ?? self.isSynchronizable)
        query[SecurityConstants.matchLimit] = kSecMatchLimitOne
        query[SecurityConstants.returnData] = kCFBooleanTrue
        // Fetch results.
        var result: AnyObject?
        switch SecItemCopyMatching(query as CFDictionary, &result) {
        case errSecItemNotFound: return nil
        case noErr: break
        case let status: throw Error.status(status)
        }
        // Return value.
        guard let data = result as? Data else { throw Error.invalidCasting }

        // Check for type.
        switch type {
        case is Data.Type:
            return data as? T
        case is Int.Type:
            return try downcast(get(NSNumber.self, forKey: key, accessible: accessibility, isSynchronizable: isSynchronizable)?.intValue)
        case is Float.Type:
            return try downcast(get(NSNumber.self, forKey: key, accessible: accessibility, isSynchronizable: isSynchronizable)?.floatValue)
        case is Double.Type:
            return try downcast(get(NSNumber.self, forKey: key, accessible: accessibility, isSynchronizable: isSynchronizable)?.doubleValue)
        case is Bool.Type:
            return try downcast(get(NSNumber.self, forKey: key, accessible: accessibility, isSynchronizable: isSynchronizable)?.boolValue)
        #if canImport(CoreGraphics)
        case is CGFloat.Type:
            return try downcast(get(Double.self, forKey: key, accessible: accessibility, isSynchronizable: isSynchronizable).flatMap(CGFloat.init))
        #endif
        default:
            // Unarchive `data`.
            var object: Any?
            if #available(iOS 12.0, macOS 10.14, tvOS 12.0, watchOS 5.0, *) {
                object = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data)
            } else {
                object = NSKeyedUnarchiver.unarchiveObject(with: data)
            }
            // Return value.
            return try downcast(object)
        }
    }

    /// Returns a stored object for a specified `key`, without throwing.
    ///
    /// Use this when the return type is unambiguous.
    /// ```swift
    /// let integer: Int = try? Keychain.default.get(key: "some-key")
    /// ```
    ///
    /// - parameters:
    ///     - key: A valid `String`.
    ///     - accessibility: An optional instance of `Accessibility`. Defaults to `nil`, meaning `self.accessibility` will be used.
    ///     - isSynchronizable: An optional `Bool`. Defaults to `nil`, meaning `self.isSynchronizable` will be used.
    /// - returns: The persisted object if found, `nil` otherwise.
    public func get<T>(forKey key: String,
                       accessible accessibility: Accessibility? = nil,
                       isSynchronizable: Bool? = nil) throws -> T? {
        return try get(T.self, forKey: key, accessible: accessibility, isSynchronizable: isSynchronizable)
    }

    /// Check for the existence of a stored object matching `key`.
    ///
    /// - parameters:
    ///     - key: A valid `String`.
    ///     - accessibility: An optional instance of `Accessibility`. Defaults to `nil`, meaning `self.accessibility` will be used.
    ///     - isSynchronizable: An optional `Bool`. Defaults to `nil`, meaning `self.isSynchronizable` will be used.
    /// - returns: `true` if a stored object was found, `false` otherwise.
    public func contains(key: String,
                         accessible accessibility: Accessibility? = nil,
                         isSynchronizable: Bool? = nil) -> Bool {
        return (try? get(Data.self, forKey: key, accessible: accessibility, isSynchronizable: isSynchronizable)) != nil
    }

    // MARK: Setters

    /// Store `value` into the keychain.
    ///
    /// - parameters:
    ///     - value: Some value.
    ///     - key: A valid `String`.
    ///     - accessibility: An optional instance of `Accessibility`. Defaults to `nil`, meaning `self.accessibility` will be used.
    ///     - isSynchronizable: An optional `Bool`. Defaults to `nil`, meaning `self.isSynchronizable` will be used.
    /// - throws: An instance of `KeychainWrapper.Error`.
    open func set<T>(_ value: T,
                     forKey key: String,
                     accessible accessibility: Accessibility? = nil,
                     isSynchronizable: Bool? = nil) throws {
        switch value {
        case let data as Data:
            // Prepare the query.
            var query: [CFString: Any] = Keychain.query(forKey: key,
                                                        service: service,
                                                        group: group,
                                                        accessible: accessibility ?? self.accessibility,
                                                        isSynchronizable: isSynchronizable ?? self.isSynchronizable)
            query[SecurityConstants.valueData] = data
            // Store results.
            switch SecItemAdd(query as CFDictionary, nil) {
            case errSecSuccess: break
            case errSecDuplicateItem:
                try update(value, forKey: key, accessible: accessibility, isSynchronizable: isSynchronizable)
            case let status: throw Error.status(status)
            }
        default:
            // Archive `value`.
            var data: Data
            if #available(iOS 12.0, macOS 10.14, tvOS 12.0, watchOS 5.0, *) {
                data = try NSKeyedArchiver.archivedData(withRootObject: value, requiringSecureCoding: false)
            } else {
                data = NSKeyedArchiver.archivedData(withRootObject: value)
            }
            // Store results.
            try set(data, forKey: key, accessible: accessibility, isSynchronizable: isSynchronizable)
        }
    }

    /// Store `value` into the keychain, when `key` is found.
    ///
    /// - parameters:
    ///     - value: Some value.
    ///     - key: A valid `String`.
    ///     - accessibility: An optional instance of `Accessibility`. Defaults to `nil`, meaning `self.accessibility` will be used.
    ///     - isSynchronizable: An optional `Bool`. Defaults to `nil`, meaning `self.isSynchronizable` will be used.
    /// - throws: An instance of `KeychainWrapper.Error`.
    private func update<T>(_ value: T,
                           forKey key: String,
                           accessible accessibility: Accessibility? = nil,
                           isSynchronizable: Bool? = nil) throws {
        // Prepare query.
        let query = Keychain.query(forKey: key,
                                   service: service,
                                   group: group,
                                   accessible: accessibility ?? self.accessibility,
                                   isSynchronizable: isSynchronizable ?? self.isSynchronizable)
        // Update attributes.
        let updateDictionary = [SecurityConstants.valueData: value]
        switch SecItemUpdate(query as CFDictionary, updateDictionary as CFDictionary) {
        case errSecSuccess: break
        case let status: throw Error.status(status)
        }
    }

    /// Remove item matching `key`.
    ///
    /// - parameters:
    ///     - key: A valid `String`.
    ///     - accessibility: An optional instance of `Accessibility`. Defaults to `nil`, meaning `self.accessibility` will be used.
    ///     - isSynchronizable: An optional `Bool`. Defaults to `nil`, meaning `self.isSynchronizable` will be used.
    /// - throws: An instance of `KeychainWrapper.Error`.
    open func remove(matchingKey key: String,
                     accessible accessibility: Accessibility? = nil,
                     isSynchronizable: Bool? = nil) throws {
        // Prepare query.
        let query: [CFString: Any] = Keychain.query(forKey: key,
                                                    service: service,
                                                    group: group,
                                                    accessible: accessibility ?? self.accessibility,
                                                    isSynchronizable: isSynchronizable ?? self.isSynchronizable)
        // Delete.
        switch SecItemDelete(query as CFDictionary) {
        case errSecSuccess, errSecItemNotFound: break
        case let status: throw Error.status(status)
        }
    }

    /// Remove all keys.
    ///
    /// - parameters:
    ///     - accessibility: An optional instance of `Accessibility`. Defaults to `nil`, meaning `self.accessibility` will be used.
    ///     - isSynchronizable: An optional `Bool`. Defaults to `nil`, meaning `self.isSynchronizable` will be used.
    /// - throws: An instance of `KeychainWrapper.Error`.
    open func removeAll() throws {
        // Prepare query.
        var query: [CFString: Any] = [SecurityConstants.class: kSecClassGenericPassword]
        query[SecurityConstants.service] = service
        query[SecurityConstants.accessGroup] = group
        // Remove items.
        switch SecItemDelete(query as CFDictionary) {
        case errSecSuccess, errSecItemNotFound: break
        case let status: throw Error.status(status)
        }
    }

    // MARK: Static

    /// Compute a base keychain query.
    ///
    /// - parameters:
    ///     - key: A valid `String`.
    ///     - service: A valid `String` representing the service name for the keychain. Defaults to the bundle identifier or `"Swiftchain"`, if `nil`.
    ///     - group: An optional `String` defining a custom access group, allowing items to be shared among apps. Defaults to `nil`.
    ///     - accessibility: Some valid `Accessibility`. Defaults to `.whenUnlocked`.
    ///     - isSynchronizable: A valid `Bool` defining whether items should be stored on iCloud or not. Defaults to `false`.
    /// - returns: A valid dictionary.
    private static func query(forKey key: String,
                              service: String,
                              group: String?,
                              accessible accessibility: Accessibility,
                              isSynchronizable: Bool) -> [CFString: Any] {
        // Prepare the query for a generic password (rather than a certificate, internet password, etc)
        var query: [CFString: Any] = [SecurityConstants.class: kSecClassGenericPassword]
        query[SecurityConstants.service] = service
        query[SecurityConstants.accessible] = accessibility.rawValue
        query[SecurityConstants.accessGroup] = group
        // Uniquely identify the account who will be accessing the keychain
        let encodedIdentifier: Data? = key.data(using: String.Encoding.utf8)
        query[SecurityConstants.generic] = encodedIdentifier
        query[SecurityConstants.account] = encodedIdentifier
        query[SecurityConstants.synchronizable] = isSynchronizable ? kCFBooleanTrue : kCFBooleanFalse
        // Return dictionary.
        return query
    }
}
