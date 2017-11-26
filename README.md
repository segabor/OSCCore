<div align="center">
    <a href="https://swift.org"><img src="https://img.shields.io/badge/Swift-4.0-orange.svg?style=flat" alt="Swift" /></a>
    <a href="https://swift.org"><img src="https://img.shields.io/badge/Platforms-OS%20X%20--%20Linux-lightgray.svg?style=flat" alt="Platform" /></a>
    <a href="https://travis-ci.org/segabor/OSCCore" alt="Travis"><img src="https://travis-ci.org/segabor/OSCCore.svg?branch=master"></a>
</div>

# OSCCore

OSCCore is a cross-platform [OpenSoundControl](http://opensoundcontrol.org/spec-1_0) implementation in pure Swift. It is aimed to run on various platforms, including embedded systems like Raspberry Pi.

Current development is done on macOS but tested on Linux/amd64 as well.

## Version history

- 0.3.1 iOS support
- 0.3 Replace socket implementation to IBM's BlueSocket
- 0.2.3 Bugfix release (see issue #5).
- 0.2.2 Improved timetag support
- 0.2.1 Bugfix: UDP Client now accepts bundles too
- 0.2 Dispatch bundle messages

## Supported Platforms

- macOS 10.12.4+ for dev, 10.9+ for deployment
- Linux
- iOS 10.0+

## Installation

To use OSCCore library, insert the following dependency into your Package.swift file 

```swift
import PackageDescription

let package = Package(
    name: "<my project name>",
    dependencies: [
        .Package(url: "https://github.com/segabor/OSCCore.git", majorVersion: 0)
    ]
)
```

Other dependency managers like CocoaPods or Chartage is under consideration.

## Roadmap

- [x] Type conversion (Convert numeric and String types to OSC packets and back)
- [x] Build OSC messages
- [x] Handle OSC bundles
- [x] Dispatch OSC messages
- [ ] Timed dispatching
- [x] Networking
- [x] Linux support

## Requirements

Swift 4.0.2 is required to build and test the module.

## Examples

### Simple OSC client

```swift
import OSCCore

let remotePort = 5051

let msg = OSCMessage(address: "/hello", args: 1234, "test")

if let client = UDPClient(host: "127.0.0.1", port: remotePort) {
    msg.send(over: client)
}
```

### Simple OSC server

```swift
let listener = UDPListener(listenerPort: 1234)
listener.listen() { receivedMessage in
    if let msg = receivedMessage as? OSCMessage {
        print("Just received a message \(receivedMessage)")
    }
    return nil
}
```

