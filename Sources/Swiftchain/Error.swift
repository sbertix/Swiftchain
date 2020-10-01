//
//  KeychainError.swift
//  
//
//  Created by Stefano Bertagno on 30/09/20.
//

import Foundation

public extension Keychain {
    /// An `enum` holding reference to keychain specific `Error`s.
    enum Error: LocalizedError {
        /// A keychain specific error.
        case status(OSStatus)
        /// Invalid downcast.
        case invalidCasting

        /// The error description.
        public var errorDescription: String? {
            switch self {
            case .status(let status):
                if #available(iOS 11.3, tvOS 11.3, watchOS 4.3, *) {
                    return SecCopyErrorMessageString(status, nil) as String? ?? String(describing: status)
                } else {
                    return String(describing: status)
                }
            case .invalidCasting: return "Invalid type casting."
            }
        }
    }
}
