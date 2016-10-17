import PackageDescription

let package = Package(
    name: "OSCClient",
    dependencies: [
        .Package(url: "../..", majorVersion: 0)
    ]
)
