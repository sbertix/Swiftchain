//
//  KeychainAuthentication.swift
//  
//
//  Created by Stefano Bertagno on 01/10/20.
//

import Foundation

public extension Keychain {
    /// A `struct` holding reference to item accessibility.
    ///
    /// - note: The option set represents the **union** of all its elements.
    ///         If you were looking for the **intersection** of all its elements,
    ///         just use `.and()` instead.
    struct Authentication: OptionSet {
        /// An `enum` representing the binary operator used to consider all options set.
        public enum Operator {
            /// `Or`. Default.
            case or
            /// `And`.
            @available(macOS 10.12.1, *)
            case and
        }

        /// The underlying value.
        public let rawValue: Int

        /// The underlying operator. Defaults to `.or`.
        public var `operator` = Operator.or

        /// Constraint to access an item with a passcode.
        @available(macOS 10.11, *)
        static let devicePasscode = Authentication(rawValue: 1 << 0)

        /// Constraint to access an item with Touch ID for any enrolled fingers, or Face ID.
        ///
        /// Touch ID must be available and enrolled with at least one finger, or Face ID must be available and enrolled.
        /// The item is still accessible by Touch ID if fingers are added or removed, or by Face ID if the user is re-enrolled.
        @available(iOS 11.3, macOS 10.13.4, tvOS 11.3, watchOS 4.3, *)
        static let biometryAny = Authentication(rawValue: 1 << 1)

        /// Constraint to access an item with Touch ID for currently enrolled fingers, or from Face ID with the currently enrolled user.
        ///
        /// Touch ID must be available and enrolled with at least one finger, or Face ID available and enrolled.
        /// The item is invalidated if fingers are added or removed for Touch ID, or if the user re-enrolls for Face ID.
        @available(iOS 11.3, macOS 10.13.4, tvOS 11.3, watchOS 4.3, *)
        static let biometryCurrentSet = Authentication(rawValue: 1 << 2)

        /// Constraint to access an item with a watch.
        ///
        /// The system attempts to locate a nearby, paired Apple Watch running watchOS 6 or later.
        @available(macOS 10.15, *)
        @available(iOS, unavailable)
        @available(tvOS, unavailable)
        @available(watchOS, unavailable)
        static let watch = Authentication(rawValue: 1 << 3)

        /// Constraint to access an item with either biometry or passcode.
        ///
        /// Biometry doesn’t have to be available or enrolled.
        /// The item is still accessible by Touch ID even if fingers are added or removed, or by Face ID if the user is re-enrolled.
        @available(macOS 10.11, *)
        static var userPresence: Authentication {
            if #available(iOS 11.3, macOS 10.13.4, tvOS 11.3, watchOS 4.3, *) {
                return [.biometryAny, .devicePasscode]
            } else {
                return .devicePasscode
            }
        }

        /// Init.
        ///
        /// - parameter rawValue: A valid `Int`.
        public init(rawValue: Int) { self.rawValue = rawValue }

        /// Init.
        ///
        /// - parameter rawValue: A valid `Int`.
        public init(rawValue: Int, operator: Operator) {
            self.rawValue = rawValue
            self.operator = `operator`
        }

        /// Update the operator.
        ///
        /// - returns: A copy of `self`.
        @available(macOS 10.12.1, *)
        public func and() -> Authentication {
            return .init(rawValue: rawValue, operator: .and)
        }

        /// Update the operator.
        ///
        /// - returns: A copy of `self`.
        public func or() -> Authentication {
            return .init(rawValue: rawValue, operator: .or)
        }

        /// Create the flags.
        ///
        /// - returns: Some `SecAccessControlCreateFlags`.
        var flags: SecAccessControlCreateFlags {
            var set: SecAccessControlCreateFlags = []
            // Prepare set.
            if #available(macOS 10.11, *), contains(.devicePasscode) {
                set.insert(.devicePasscode)
            }
            if #available(iOS 11.3, macOS 10.13.4, tvOS 11.3, watchOS 4.3, *),
               contains(.biometryAny) {
                set.insert(.biometryAny)
            }
            if #available(iOS 11.3, macOS 10.13.4, tvOS 11.3, watchOS 4.3, *),
               contains(.biometryCurrentSet) {
                set.insert(.biometryCurrentSet)
            }
            #if os(macOS)
            if #available(macOS 10.15, *), contains(.watch) { set.insert(.watch) }
            #endif
            // Add operators.
            if #available(macOS 10.12.1, *) {
                if self.operator == .and {
                    set.insert(.and)
                } else {
                    set.insert(.or)
                }
            }
            // Return.
            return set
        }
    }
}
