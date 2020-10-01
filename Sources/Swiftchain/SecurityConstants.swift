//
//  SecurityConstants.swift
//  
//
//  Created by Stefano Bertagno on 30/09/20.
//

import Foundation

/// A `struct` holding reference to all `CFString` identifiers.
enum SecurityConstants {
    /// `kSecMatchLimit`
    static let matchLimit = kSecMatchLimit
    /// `kSecReturnData`
    static let returnData = kSecReturnData
    /// `kSecReturnPersistentRef`
    static let reference = kSecReturnPersistentRef
    /// `kSecValueData`
    static let valueData = kSecValueData
    /// `kSecAttrAccessible`
    static let accessible = kSecAttrAccessible
    /// `kSecAttrAccessControl`
    static let control = kSecAttrAccessControl
    /// `kSecClass`
    static let `class` = kSecClass
    /// `kSecAttrService`
    static let service = kSecAttrService
    /// `kSecAttrGeneric`
    static let generic = kSecAttrGeneric
    /// `kSecAttrAccount`
    static let account = kSecAttrAccount
    /// `kSecAttrAccessGroup`
    static let accessGroup = kSecAttrAccessGroup
    /// `kSecReturnAttributes`
    static let attributes = kSecReturnAttributes
    /// `kSecAttrSynchronizable`
    static let synchronizable = kSecAttrSynchronizable
}
