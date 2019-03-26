// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "OSCCore",

    products: [
        .library(name: "OSCCore", targets: ["OSCCore"]),
        .executable(name: "BasicListener", targets: ["BasicListener"])
    ],

    dependencies: [
        .package(url: "https://github.com/apple/swift-nio", from: "2.0.0")
    ],

    targets: [
        .target(name: "OSCCore", dependencies: ["NIO"]),
        .target(name: "BasicListener", dependencies: ["OSCCore", "NIO"]),

        .testTarget(name: "OSCCoreTests", dependencies: ["OSCCore"])
    ]
)
