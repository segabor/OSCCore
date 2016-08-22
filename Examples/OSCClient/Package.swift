import PackageDescription

let package = Package(
    name: "OSCClient",
    dependencies: [
        .Package(url: "https://github.com/segabor/UDP.git", "0.6.1"),
        .Package(url: "../..", majorVersion: 0)
    ]
)
