<div align="center">
    <a href="https://swift.org"><img src="https://img.shields.io/badge/Swift-3.0-orange.svg?style=flat" alt="Swift" /></a>
    <a href="https://swift.org"><img src="https://img.shields.io/badge/Platforms-OS%20X%20--%20Linux-lightgray.svg?style=flat" alt="Platform" /></a>
    <a href="https://travis-ci.org/segabor/OSCCore" alt="Travis"><img src="https://travis-ci.org/segabor/OSCCore.svg?branch=master"></a>
    <a href="https://codecov.io/gh/segabor/OSCCore"><img src="https://codecov.io/gh/segabor/OSCCore/branch/master/graph/badge.svg" alt="Codecov" /></a>
</div>

# OSCCore

This is a tiny module that implements [OpenSoundControl](http://opensoundcontrol.org/spec-1_0) protocol in pure Swift.

## Installation

```swift
import PackageDescription

let package = Package(
    name: "<my project name>",
    dependencies: [
        .Package(url: "https://github.com/segabor/OSCCore.git", majorVersion: 0)
    ]
)
```

## Roadmap

- [x] Type conversion (Convert numeric and String types to OSC packets and back)
- [x] Build OSC messages
- [x] Handle OSC bundles
- [x] Dispatch OSC messages
- [ ] Timed dispatching
- [x] Networking
- [x] Linux support

## Requirements

Swift 3 is required to build and test the module.

## Examples

### Simple OSC client

```swift
import OSCCore

let clientPort    = 5050
let remotePort    = 5051

let msg = OSCMessage(address: "/hello", args: 1234, "test")

if let client = UDPClient(port: clientPort, remotePort: remotePort) {
  try client.send(message: msg)
}
```

### Simple OSC server
```
import OSCCore

if let srv = try? OSCServer(port: 5050) {
  srv.register(pattern: "/hello") { (msg: OSCMessage) in
    
    print("Address: \(msg.address)")
    msg.args.forEach { arg in
      print("arg: \(arg)")
    }
  }

  srv.listen()
}
```

For details, see Examples folder.
