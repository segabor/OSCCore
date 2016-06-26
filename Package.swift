import PackageDescription

let package = Package(
    name: "OSCCore",
    dependencies: [
        .Package(url: "https://github.com/VeniceX/UDP.git", majorVersion: 0, minor: 6)
    ]
)

