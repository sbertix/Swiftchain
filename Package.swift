// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "Swiftchain",
    platforms: [
        .iOS(.v9),
        .macOS(.v10_10),
        .tvOS(.v9),
        .watchOS(.v2)
    ],
    products: [
        .library(
            name: "Swiftchain",
            targets: ["Swiftchain"]
        ),
    ],
    targets: [
        .target(
            name: "Swiftchain",
            dependencies: []
        ),
        .testTarget(
            name: "SwiftchainTests",
            dependencies: ["Swiftchain"]
        ),
    ]
)
