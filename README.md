<div align="center">
    <a href="https://swift.org"><img src="https://img.shields.io/badge/Swift-4.0-orange.svg?style=flat" alt="Swift" /></a>
    <a href="https://swift.org"><img src="https://img.shields.io/badge/Platforms-macOS%20--%20iOS%20--%20Linux-lightgray.svg?style=flat" alt="Platform" /></a>
    <a href="https://travis-ci.org/segabor/OSCCore" alt="Travis"><img src="https://travis-ci.org/segabor/OSCCore.svg?branch=master"></a>
</div>

# OSCCore

OSCCore is a [OpenSoundControl](http://opensoundcontrol.org/spec-1_0) implementation in pure Swift. It is aimed to run on various platforms, including embedded systems like Raspberry Pi.

Using this module you can easily pass or receive OSC messages, communicate with SuperCollider or other great digital musical instruments.
OSC is also great for implmenenting other protocols like TUIO.

## Composing OSC Messages

To create a message simply instantiate `OSCMessage` class, assign address and parameters to it.

```swift
let msg = OSCMessage("/instr/osc1", ["frequency", 440.0])
```

OSC parameters can be any of the following
- null value: `nil`
- boolean values: `true`, `false`
- characters: `Character("a")`
- strings
- numerical values: integers, floats and doubles
- MIDI and RGBA values
- OSC symbols: `OSCSymbol(label: symbolName)`
- Array of parameters: `[Int32(0x12345678), "hello"]`
- Blobs: `[UInt8](0xde, 0xad, 0xfa, 0xce)`

## OSC Bundles

Bundles are mixed list of messages and other bundles. They also carry a time stamp or time tag.

The following bundle when received by SuperCollider will create a new synth instance with the given frequency and amplitude in parameters.

```swift
let synthID = Int32(4)

let synthBundle = OSCBundle(timetag: OSCTimeTag.immediate, content: [
    // "/s_new", name, node ID, pos, group ID
    OSCMessage(address: "/s_new", args: ["sine", synthID, Int32(1), Int32(1)]),
    // "/n_set", "amp", sine amplitude
    OSCMessage(address: "/n_set", args: [synthID, "amp", Float32(0.5)]),
    // "/n_set", "freq", sine frequency
    OSCMessage(address: "/n_set", args: [synthID, "freq", Float32(440.0)])
])
```

## Sending and receiving OSC messages

OSCCore is built on top of [SwiftNIO](https://github.com/apple/swift-nio), a asynchronous event-driven network application framework developed by Apple.

For examples please see BasicListener and SuperColliderExample projects in Source folder.

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

