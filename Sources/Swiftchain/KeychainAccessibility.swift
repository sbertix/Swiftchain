//
//  KeychainAccessibility.swift
//  
//
//  Created by Stefano Bertagno on 30/09/20.
//

import Foundation

public extension Keychain {
    /// A `struct` holding reference to item accessibility.
    struct Accessibility: Hashable, RawRepresentable {
        /// The underlying value.
        public let rawValue: CFString

        /// The data in the keychain item cannot be accessed after a restart until the device has been unlocked once by the user.
        ///
        /// After the first unlock, the data remains accessible until the next restart.
        /// This is recommended for items that need to be accessed by background applications.
        /// Items with this attribute migrate to a new device when using encrypted backups.
        public static let afterFirstUnlock = Accessibility(rawValue: kSecAttrAccessibleAfterFirstUnlock)

        /// The data in the keychain item cannot be accessed after a restart until the device has been unlocked once by the user.
        ///
        /// After the first unlock, the data remains accessible until the next restart.
        /// This is recommended for items that need to be accessed by background applications.
        /// Items with this attribute do not migrate to a new device.
        ///  Thus, after restoring from a backup of a different device, these items will not be present.
        public static let afterFirstUnlockThisDeviceOnly = Accessibility(rawValue: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly)

        /// The data in the keychain can only be accessed when the device is unlocked. Only available if a passcode is set on the device.
        ///
        /// This is recommended for items that only need to be accessible while the application is in the foreground.
        /// Items with this attribute never migrate to a new device.
        /// After a backup is restored to a new device, these items are missing.
        /// No items can be stored in this class on devices without a passcode.
        /// Disabling the device passcode causes all items in this class to be deleted.
        public static let whenPasscodeSetThisDeviceOnly = Accessibility(rawValue: kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly)

        /// The data in the keychain item can be accessed only while the device is unlocked by the user.
        ///
        /// This is recommended for items that need to be accessible only while the application is in the foreground.
        /// Items with this attribute migrate to a new device when using encrypted backups.
        /// This is the default value for keychain items added without explicitly setting an accessibility constant.
        public static let whenUnlocked = Accessibility(rawValue: kSecAttrAccessibleWhenUnlocked)

        /// The data in the keychain item can be accessed only while the device is unlocked by the user.
        ///
        /// This is recommended for items that need to be accessible only while the application is in the foreground.
        /// Items with this attribute do not migrate to a new device.
        /// Thus, after restoring from a backup of a different device, these items will not be present.
        public static let whenUnlockedThisDeviceOnly = Accessibility(rawValue: kSecAttrAccessibleWhenUnlockedThisDeviceOnly)

        /// Init.
        ///
        /// - parameter rawValue: A valid `CFString`.
        public init(rawValue: CFString) { self.rawValue = rawValue }
    }
}
