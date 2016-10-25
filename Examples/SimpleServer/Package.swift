import PackageDescription

let package = Package(
    name: "SimpleServer",
    dependencies: [
        .Package(url: "../..", majorVersion: 0)
    ]
)
