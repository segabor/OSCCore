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
        .package(url: "https://github.com/IBM-Swift/BlueSocket", from: "0.12.0")
    ],

    targets: [
        .target(name: "OSCCore", dependencies: ["Socket"]),
        .target(name: "BasicListener", dependencies: ["OSCCore"]),
        .target(name: "SuperColliderExample", dependencies: ["OSCCore"]),

        .testTarget(name: "OSCCoreTests", dependencies: ["OSCCore"])
    ]
)
