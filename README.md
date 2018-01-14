<div align="center">
    <a href="https://swift.org"><img src="https://img.shields.io/badge/Swift-4.0-orange.svg?style=flat" alt="Swift" /></a>
    <a href="https://swift.org"><img src="https://img.shields.io/badge/Platforms-macOS%20--%20iOS%20--%20Linux-lightgray.svg?style=flat" alt="Platform" /></a>
    <a href="https://travis-ci.org/segabor/OSCCore" alt="Travis"><img src="https://travis-ci.org/segabor/OSCCore.svg?branch=master"></a>
</div>

# OSCCore

OSCCore is a [OpenSoundControl](http://opensoundcontrol.org/spec-1_0) implementation in pure Swift. It is aimed to run on various platforms, including embedded systems like Raspberry Pi.

Using this module you can easily pass or receive OSC messages, communicate with SuperCollider or other great digital musical instruments.
OSC is also great for implmenenting other protocols like TUIO.

Passing messages is easy, just create an OSCMessage and send it. A message is composed of address and arguments.
Address is like an URI, starting with slash character. Arguments tipically are simple strings and numbers.

```swift
import OSCCore

let msg = OSCMessage("/instr/osc1", ["frequency", 440.0])
```


The next thing is to open channel.

```swift
let channel: UDPClient? = UDPClient(host: "127.0.0.1", port: 57110)
```

Once you have an open channel, send your message.

```swift
msg.send(over: channel)
```

That's all! For more examples please see Sources folder.

## Usage

OSCCore is currently provided as Swift PackageManager module. To include OSCCore to your project add the following dependency to your Package.swift file

```swift
.Package(url: "https://github.com/segabor/OSCCore.git", majorVersion: 0)
```

Other dependency managers like CocoaPods or Chartage is under consideration.

## Version history

- 0.9 OSC Specification 1.0
- 0.4 Important fixes: timestamp and OSC packet detection
  Switch to Swift 4.0.2
- 0.3.1 iOS support
  Note: this is last Swift 3 supported version
- 0.3 Replace socket implementation to IBM's BlueSocket
- 0.2.3 Bugfix release (see issue #5).
- 0.2.2 Improved timetag support
- 0.2.1 Bugfix: UDP Client now accepts bundles too
- 0.2 Dispatch bundle messages

