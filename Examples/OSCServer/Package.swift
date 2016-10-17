import PackageDescription

let package = Package(
    name: "OSCServer",
    dependencies: [
        .Package(url: "../..", majorVersion: 0)
    ]
)
