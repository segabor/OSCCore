//
//  DispatcherTests.swift
//  OSCCore
//
//  Created by Gábor Sebestyén on 13/08/16.
//
//

@testable import OSCCore
import XCTest

#if os(Linux)
import Foundation
#endif

class DispatcherTests: XCTestCase {

    func testDispatchWithMatchingAddresses() {
        doTestDispatch(pattern: "/test/1", event: MessageEvent(when: Date(), message: OSCMessage(address: "/test/1", args: 1234)), expected: true)

        doTestDispatch(pattern: "/test/*", event: MessageEvent(when: Date(), message: OSCMessage(address: "/test/1", args: 1234)), expected: true)

        doTestDispatch(pattern: "/test/*", event: MessageEvent(when: Date(), message: OSCMessage(address: "/test/2", args: 1234)), expected: true)
    }

    func testDispatchWithNonMatchingAddresses() {
        doTestDispatch(pattern: "/test/1", event: MessageEvent(when: Date(), message: OSCMessage(address: "/test/2", args: 1234)), expected: false)

        doTestDispatch(pattern: "/test/1", event: MessageEvent(when: Date(), message: OSCMessage(address: "/tezt/1", args: 1234)), expected: false)

        doTestDispatch(pattern: "/tezt/*", event: MessageEvent(when: Date(), message: OSCMessage(address: "/test/1", args: 1234)), expected: false)

        doTestDispatch(pattern: "/tezt/*", event: MessageEvent(when: Date(), message: OSCMessage(address: "/test/2", args: 1234)), expected: false)
    }

    private func doTestDispatch(pattern ptn: String, event: MessageEvent, expected: Bool) {
        let mgr = BasicMessageDispatcher()

        var flag = false

        mgr.register(pattern: ptn) {_ in
            flag = true
        }

        mgr.fire(event: event)

        XCTAssertTrue(flag == expected)

    }
}

#if os(Linux)
  extension DispatcherTests {
    static var allTests: [(String, (DispatcherTests) -> () throws -> Void)] {
      return [
        ("testDispatchWithMatchingAddresses", testDispatchWithMatchingAddresses),
        ("testDispatchWithNonMatchingAddresses", testDispatchWithNonMatchingAddresses)
      ]
    }
  }
#endif
