<p align="center">
    <a href="https://swift.org"><img src="https://img.shields.io/badge/Swift-3.0-orange.svg?style=flat" alt="Swift" /></a>
    <a href="https://swift.org"><img src="https://img.shields.io/badge/Platforms-OS%20X%20--%20Linux-lightgray.svg?style=flat" alt="Platform" /></a>
    <a href="https://travis-ci.org/segabor/OSCCore" alt="Travis"><img src="https://travis-ci.org/segabor/OSCCore.svg?branch=master"></a>
</p>

# OSCCore

This is a tiny module that implements [OpenSoundControl](http://opensoundcontrol.org/spec-1_0) protocol in pure Swift.
Currently only OSX is supported but Linux support is on the way (see Issue #1).

## Roadmap

- [x] Type conversion (Convert numeric and String types to OSC packets and back)
- [x] Build OSC messages
- [ ] Handle OSC bundles
- [ ] Dispatch OSC messages
- [x] Networking
- [x] Linux support

## Requirements

Swift 3 is required to build and test the module.

## Usage

See projects in Examples folder.
