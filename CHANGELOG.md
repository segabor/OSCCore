# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.11] - 2022-05-07
### Changed
- Fixed a bug prevented receiving packets (issues #24 and #25)
  Thanks @mron
- Switch to Swift 5.4

## [0.10] - 2018-08-30
### Changed
- Switch networking to Swift NIO

## [0.9] - 2018-01-14
### Added
- OSC Specification 1.0

## [0.4] - 2018-01-14
### Changed
- Fix broken OSC timestamp serialization and date conversion
- OSCBundles were not recognized
- Switch to Swift 4.0.2

## [0.3.1] - 2017-05-15
### Added
- iOS support
  Note: this is last Swift 3 supported version

## [0.3]
### Changed
- Replace socket implementation to IBM's BlueSocket

## [0.2.3] - 2017-05-17
### Changed
- Bugfix release (see issue #5).

## [0.2.2]
### Changed
- Improved timetag support

## [0.2.1]
### Changed
- UDP Client now accepts bundles too

## [0.2]
### Added
- Dispatch bundle messages
