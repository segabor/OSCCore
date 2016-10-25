import PackageDescription

let package = Package(
    name: "SimpleClient",
    dependencies: [
        .Package(url: "../..", majorVersion: 0)
    ]
)
