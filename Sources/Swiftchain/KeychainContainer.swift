//
//  KeychainContainer.swift
//  
//
//  Created by Stefano Bertagno on 01/10/20.
//

#if canImport(CoreGraphics)
import CoreGraphics
#endif

import Foundation

public extension Keychain {
    /// A `struct` holding reference to a particular storage space inside your `Keychain`,
    /// identified by a unique identifier, `key`.
    final class Container {
        /// The underlying keychain.
        public private(set) var keychain: Keychain
        /// The identifier.
        public private(set) var key: String

        /// Compute a base keychain query.
        private var query: [CFString: Any] {
            // Prepare the query for a generic password (rather than a certificate, internet password, etc)
            var query: [CFString: Any] = [SecurityConstants.class: kSecClassGenericPassword]
            query[SecurityConstants.service] = keychain.service
            query[SecurityConstants.accessible] = keychain.accessibility.rawValue
            query[SecurityConstants.accessGroup] = keychain.group
            // Uniquely identify the account who will be accessing the keychain
            let encodedIdentifier: Data = key.data(using: String.Encoding.utf8)!
            query[SecurityConstants.generic] = encodedIdentifier
            query[SecurityConstants.account] = encodedIdentifier
            query[SecurityConstants.synchronizable] = keychain.isSynchronizable ? kCFBooleanTrue : kCFBooleanFalse
            // Return dictionary.
            return query
        }

        /// Check whether it's empty or not.
        ///
        /// - note: A `Container` throwing an `Error` is considered empty.
        public var isEmpty: Bool {
            return (try? fetch(Data.self)) == nil
        }

        // MARK: Lifecycle

        /// Init.
        ///
        /// - parameters:
        ///     - keychain: A valid `Keychain`.
        ///     - id: Some valid `String`.
        /// - note: Use `Keychain.container` instead.
        init(keychain: Keychain, key: String) {
            self.keychain = keychain
            self.key = key
        }

        // MARK: Setters

        /// Update the underlying item.
        ///
        /// - parameter value: Some valid element.
        /// - throws: A `Keychain.Error` or `Swift.Error`.
        public func store<T>(_ value: T) throws {
            switch value {
            case let data as Data:
                // Prepare the query.
                var query: [CFString: Any] = self.query
                query[SecurityConstants.valueData] = data
                // Store results.
                switch Keychain.locking({ SecItemAdd(query as CFDictionary, nil) }) {
                case errSecSuccess: break
                case errSecDuplicateItem: try update(value)
                case let status: print(status); throw Error.status(status)
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
                try store(data)
            }
        }

        /// Store `value` into the keychain, when `key` is found.
        ///
        /// - parameter value: Some valid element.
        /// - throws: An instance of `Keychain.Error`.
        private func update<T>(_ value: T) throws {
            // Update attributes.
            let updateDictionary = [SecurityConstants.valueData: value]
            switch Keychain.locking({ SecItemUpdate(query as CFDictionary, updateDictionary as CFDictionary) }) {
            case errSecSuccess: break
            case let status: throw Error.status(status)
            }
        }

        /// Empty container and return former value, if it exists.
        ///
        /// - parameter type: Some instance type.
        /// - throws: Some `Keychain.Error`.
        /// - returns: Some valid element.
        public func drop<T>(_ type: T.Type) throws -> T? {
            // We're not using `defer` as it cannot `throw`.
            let value = try fetch(type)
            try empty()
            return value
        }

        /// Empty container and return former value, if it exists.
        ///
        /// - throws: Some `Keychain.Error`.
        /// - returns: Some valid element.
        public func drop<T>() throws -> T? {
            return try drop(T.self)
        }

        /// Empty container.
        ///
        /// - throws: Some `Keychain.Error`.
        public func empty() throws {
            // Delete.
            switch Keychain.locking({ SecItemDelete(query as CFDictionary) }) {
            case errSecSuccess, errSecItemNotFound: break
            case let status: throw Error.status(status)
            }
        }

        // MARK: Getters

        /// Fetch the underlying item.
        ///
        /// - throws: A `Keychain.Error`.
        /// - returns: An optional element.
        public func fetch<T>(_ type: T.Type) throws -> T? {
            // Downcast or throw.
            func downcast<S>(_ value: S?) throws -> T? {
                guard let value = value else { return nil }
                guard let result = value as? T else { throw Error.invalidCasting }
                return result
            }

            // Prepare the query.
            var query = self.query
            query[SecurityConstants.matchLimit] = kSecMatchLimitOne
            query[SecurityConstants.returnData] = kCFBooleanTrue
            // Fetch results.
            var result: AnyObject?
            switch Keychain.locking({ SecItemCopyMatching(query as CFDictionary, &result) }) {
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
                return try downcast(fetch(NSNumber.self)?.intValue)
            case is Float.Type:
                return try downcast(fetch(NSNumber.self)?.floatValue)
            case is Double.Type:
                return try downcast(fetch(NSNumber.self)?.doubleValue)
            case is Bool.Type:
                return try downcast(fetch(NSNumber.self)?.boolValue)
            #if canImport(CoreGraphics)
            case is CGFloat.Type:
                return try downcast(fetch(Double.self).flatMap(CGFloat.init))
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

        /// Fetch the underlying item.
        ///
        /// - throws: A `Keychain.Error`.
        /// - returns: An optional element.
        public func fetch<T>() throws -> T? {
            return try fetch(T.self)
        }
    }
}
