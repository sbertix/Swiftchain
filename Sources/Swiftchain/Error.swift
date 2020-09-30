//
//  KeychainError.swift
//  
//
//  Created by Stefano Bertagno on 30/09/20.
//

import Foundation

public extension Keychain {
    /// An `enum` holding reference to keychain specific `Error`s.
    enum Error: Swift.Error {
        /// A keychain specific error.
        case status(OSStatus)
        /// Invalid downcast.
        case invalidCasting
    }
}
