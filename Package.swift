import PackageDescription

let package = Package(
    name: "OSCCore",

    dependencies: [
        .Package(url: "https://github.com/IBM-Swift/BlueSocket", majorVersion: 0, minor: 12)
    ]
)
