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

        // MARK: Insertion

        /// Clean the container and store a new item.
        ///
        /// - parameter value: Some valid element.
        /// - note: If an `Error` is thrown during the process, the `container` would still be emptied.
        /// - throws: A `Keychain.Error` or `Swift.Error`.
        public func store<T>(_ value: T) throws {
            switch value {
            case let data as Data:
                // Always empty the `Container`, before storing a new value.
                try empty()

                // Prepare the query.
                let constants: SecurityConstants = [.key, .value, .keychain, .accessibility, .authentication]
                let query = try constants.query(for: self, with: data)
                // Store results.
                switch Keychain.locking({ SecItemAdd(query as CFDictionary, nil) }) {
                case errSecSuccess: break
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
                try store(data)
            }
        }

        /// Copy the content of `self`, into another `container`.
        ///
        /// - parameter container: A valid `Container`.
        /// - throws: Some `Keychain.Error`.
        /// - warning: If `self` fetches `nil`, or throws an `Error`, `container` **will be emptied**.
        public func copy(to container: Container) throws {
            switch try fetch(Data.self) {
            case let data?: try container.store(data)
            default: try container.empty()
            }
        }

        // MARK: Deletion

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
            // Prepare query.
            let constants: SecurityConstants = [.key, .keychain]
            let query = try constants.query(for: self)
            // Delete.
            switch Keychain.locking({ SecItemDelete(query as CFDictionary) }) {
            case errSecSuccess, errSecItemNotFound: break
            case let status: throw Error.status(status)
            }
        }

        /// Move the content of `self`, into another `container`.
        ///
        /// - parameter container: A valid `Container`.
        /// - throws: Some `Keychain.Error`.
        /// - warning: If `self` fetches `nil`, or throws an `Error`, `container` **will be emptied**.
        public func move(to container: Container) throws {
            switch try fetch(Data.self) {
            case let data?: try container.store(data)
            default: try container.empty()
            }
            // Empty `self`.
            try empty()
        }

        // MARK: Accessories

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
            let constants: SecurityConstants = [.key, .data, .one, .keychain]
            let query = try constants.query(for: self)
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
