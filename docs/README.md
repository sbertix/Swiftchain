# Swiftchain
[![Swift](https://img.shields.io/badge/Swift-5.0-%23DE5C43?style=flat&logo=swift)](https://swift.org)
[![codecov](https://codecov.io/gh/sbertix/Swiftchain/branch/main/graph/badge.svg)](https://codecov.io/gh/sbertix/Swiftchain)

**Swiftchain** is a lightweight Keychain wrapper written entirely in **Swift**, simplifying access to a safe and secure form of storage.  

<br/>

> Where can I use this?

**Swiftagram** supports **iOS**, **macOS**, **tvOS** and **watchOS**.

## Status
![Test](https://github.com/sbertix/Swiftchain/workflows/test/badge.svg)
[![GitHub tag (latest by date)](https://img.shields.io/github/v/tag/sbertix/Swiftchain)](https://github.com/sbertix/Swiftchain/wiki)

<br />

> What's next?

Check out our [milestones](https://github.com/sbertix/Swiftchain/milestones) and [issues](https://github.com/sbertix/Swiftchain/issues).

[Pull requests](https://github.com/sbertix/Swiftchain/pulls) are more than welcome.\
Just remember to refer to our [guidelines](CONTRIBUTING.md) and [Code of Conduct](CODE_OF_CONDUCT.md), when you contribute.

## Installation
### Swift Package Manager (Xcode 11 and above)
1. Select `File`/`Swift Packages`/`Add Package Dependency…` from the menu.
1. Paste `https://github.com/sbertix/Swifthcain.git`.
1. Follow the steps.

<br />

> Why not CocoaPods, or Carthage, or ~blank~?

Supporting multiple _dependency managers_ makes maintaining a library exponentially more complicated and time consuming.\
Furthermore, with the integration of the **Swift Package Manager** in **Xcode 11** and greater, we expect the need for alternative solutions to fade quickly.

## Usage

With the creation of a  `Keychain` instance, a _service name_ is associated to any value safely stored in your device keychain. 
This defaults to your bundle identifier, if it exists, or a constant string you can exepct not to change in future versions, otherwise. 

You might need to share your keychain items between apps: in that case just share the same _access group_ among them. 

By default, all stored items, can only be accessed when the device is unlocked, but you can simply select a new default `Keychain.Accessibility` (and _authorization_) type when `init`-iating the `Keychain`, together with an iCloud synchronization rule: out-of-the-box nothing is shared to the cloud.   

<details><summary><strong>Accessibility</strong> vs <strong>authentication</strong></summary>
    <p>
    
Please refer to the official [Apple documentation](https://developer.apple.com/documentation/security/keychain_services/keychain_items/restricting_keychain_item_accessibility) in order to better understand _accessibility_ and _authentication_. 

> What if I need to access my keychain items in the background?

Change your `accessibility`. For instance, you could use `.afterFirstUnlock`.

> What if I need to make sure biometric authentication is on for the device?

Change your `authentication`. For instance, you could use `.biometricsAny`.
    </p>
</details>

```swift
// You can either call a shared instance…
var keychain = Keychain.default
// … or create your own!
keychain = Keychain(service: "com.sbertix.custom",      // Optional.
                    group: "com.sbertix.group",         // Optional.
                    accessibility: .afterFirstUnlock,   // Optional.
                    authentication: .biometryAny,       // Optional.
                    isSynchronizable: true)             // Optional.
```

<br />

> How about storing and retreiving items?

And then just start storing and retreiving your items!

```swift
let username: String = /* some String */
let password: String = /* some String */

// Store the password.
try? keychain.container(for: username).store(password)

/* later */

let container = keychain.container(for: username)
// Retrieve the password.
let secret = try? container.fetch(String.self)
// Or even simpler, if it's unambiguous.
let string: String? = try? container.fetch(username)
```

Please keep in mind, you **cannot** modify accessibility or synchronization options for a given item, without removing it first, but the easiest way is actually copying or moving values accross `Container`s`. 

```swift
// Empty the container.
try? container.empty()
// Store it again…

/* or */
// Another container, with some different synchronization or accessibility.
let anotherContainer: Container = /* some Container */
// Copy the content of `container` to `anotherContainer`.
try? container.copy(to: anotherContainer) 
// Copy the content of `container` to `anotherContainer`, then erase `container`.
try? container.move(to: anotherContainer)
```

<br />

> Can I override the default `Keychain` when only relying on different settings, for instance?

Sure.

```swift
// Just set a new one.
Keychain.default = Keychain(accessibility: .afterFirstUnlock,
                            isSynchronizable: true)
```

## Special thanks

> _Massive thanks to anyone contributing to [jrendel/SwiftKeychainWrapper](https://github.com/jrendel/SwiftKeychainWrapper) and [evgenyneu/keychain-swift](https://github.com/evgenyneu/keychain-swift), for the inspiration and the invaluable service to the open source community, without which there would likely be no **Swiftchain** today._
