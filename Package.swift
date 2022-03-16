// swift-tools-version:5.4

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
        .target(name: "OSCCore", dependencies: [
            .product(name: "NIO", package: "swift-nio")
        ]),
        .executableTarget(name: "BasicListener", dependencies: ["OSCCore"], path: "Examples/BasicListener", exclude: ["README.md"]),
        .executableTarget(name: "SoundColliderClient", dependencies: ["OSCCore"], path: "Examples/SoundColliderClient"),

        .testTarget(name: "OSCCoreTests", dependencies: ["OSCCore"])
    ]
)
