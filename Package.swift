// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "OSCCore",

    products: [
        .library(name: "OSCCore", targets: ["OSCCore"]),
        .executable(name: "BasicListener", targets: ["BasicListener"]),
        .executable(name: "SuperColliderExample", targets: ["SuperColliderExample"])
    ],

    dependencies: [
        .package(url: "https://github.com/apple/swift-nio", from: "1.7.2")
    ],

    targets: [
        .target(name: "OSCCore", dependencies: []),
        .target(name: "BasicListener", dependencies: ["OSCCore", "NIO"]),
        .target(name: "SuperColliderExample", dependencies: ["OSCCore", "NIO"]),

        .testTarget(name: "OSCCoreTests", dependencies: ["OSCCore"])
    ]
)
