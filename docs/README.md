# Swiftchain
[![Swift](https://img.shields.io/badge/Swift-5.0-%23DE5C43?style=flat&logo=swift)](https://swift.org)
[![codecov](https://codecov.io/gh/sbertix/Swiftchain/branch/main/graph/badge.svg)](https://codecov.io/gh/sbertix/Swiftchain)

**Swiftchain** is a Keychain wrapper written entirely in **Swift**, in order to simplify access and usage to a safe and secure storage. 
Anyone relying on `UserDefaults` should be comfortable with this library. 

<br/>

> Where can I use this?

**Swiftagram** supports **iOS**, **macOS**, **tvOS** and **watchOS**.

## Status
![Test](https://github.com/sbertix/Swiftchain/workflows/test/badge.svg)
[![GitHub tag (latest by date)](https://img.shields.io/github/v/tag/sbertix/Swiftchain)](https://github.com/sbertix/Swiftchain/wiki)

> What's next?

Check out our [milestones](https://github.com/sbertix/Swiftchain/milestones) and [issues](https://github.com/sbertix/Swiftchain/issues).

[Pull requests](https://github.com/sbertix/Swiftchain/pulls) are more than welcome.\
Just remember to refer to our [guidelines](CONTRIBUTING.md) and [Code of Conduct](CODE_OF_CONDUCT.md), when you contribute.

## Installation
### Swift Package Manager (Xcode 11 and above)
1. Select `File`/`Swift Packages`/`Add Package Dependency…` from the menu.
1. Paste `https://github.com/sbertix/Swifthcain.git`.
1. Follow the steps.

> Why not CocoaPods, or Carthage, or ~blank~?

Supporting multiple _dependency managers_ makes maintaining a library exponentially more complicated and time consuming.\
Furthermore, with the integration of the **Swift Package Manager** in **Xcode 11** and greater, we expect the need for alternative solutions to fade quickly.

## Usage

With the creation of a  `Keychain` instance, a _service name_ is associated to any value safely stored in your device keychain. 
This defaults to your bundle identifier, if it exists, or a constant string you can exepct not to change in future versions, otherwise. 

You might need to share your keychain items between apps, in that case you need an _access group_ and share it among them. 

Furthermore, by default, all stored items, can only be accessed when the device is unlocked, but you can simply select a new default `Keychain.Accessibility` type when `init`-iating the `Keychain` or by temporarily referring to a new one in specific methods.  
Same goes for iCloud synchronization. Out-of-the-box all items are not shared to the cloud, but it's quick and easy to change this setting. 

```swift
// You can either call a shared instance…
var keychain = Keychain.default
// … or create your own!
keychain = Keychain(service: "com.sbertix.custom", 
                    group: "com.sbertix.group", 
                    accessibility: .afterFirstUnlock,
                    isSynchronizable: true)
```

And then just start storing and retreiving your items!

```swift
let username: String = /* some String */
let password: String = /* some String */

// Store the password.
try? keychain.set(password, forKey: username)

/* later */

// Retrieve the password.
let secret = try? keychain.get(String.self, forKey: username)
// Or even simpler, if it's unambiguous.
let string: String? = try? keychain.get(forKey: username)
```

Please keep in mind, you **cannot** modify accessibility or synchronization options for a given item, without removing it first. 

```swift
// Remove it first.
try? keychain.remove(matchingKey: username)
// Save it again.
try? keychain.set(password, 
                  forKey: username, 
                  accessible: .afterFirstUnlockThisDeviceOnly,
                  isSynchronizable: false)
```

## Special thanks

> _Massive thanks to anyone contributing to [jrendel/SwiftKeychainWrapper](https://github.com/jrendel/SwiftKeychainWrapper) and [evgenyneu/keychain-swift](https://github.com/evgenyneu/keychain-swift), for the inspiration and the invaluable service to the open source community, without which there would likely be no **Swiftchain** today._
