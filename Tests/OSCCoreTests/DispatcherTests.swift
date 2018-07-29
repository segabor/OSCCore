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

    func testDispatchWithMatchingAddress() {
        let testEvent = MessageEvent(when: Date(), message: OSCMessage(address: "/test/1", args: [1234]))

        doTestDispatch(pattern: "/test/1", event: testEvent, expected: true)
    }

    func testDispatchWithMatchingAddresses() {
        let testEvent = MessageEvent(when: Date(), message: OSCMessage(address: "/test/1", args: [1234]))

        doTestDispatch(pattern: "/test/*", event: testEvent, expected: true)
    }

    func testDispatchWithNonMatchingSubComponents() {
        let testEvent = MessageEvent(when: Date(), message: OSCMessage(address: "/test/2", args: [1234]))

        doTestDispatch(pattern: "/test/1", event: testEvent, expected: false)
    }

    func testDispatchWithNonMatchingRootComponents() {
        let testEvent = MessageEvent(when: Date(), message: OSCMessage(address: "/tezt/1", args: [1234]))

        doTestDispatch(pattern: "/test/1", event: testEvent, expected: false)
    }

    func testDispatchWithNonMatchingAddresses() {
        let testEvent = MessageEvent(when: Date(), message: OSCMessage(address: "/test/1", args: [1234]))

        doTestDispatch(pattern: "/tezt/*", event: testEvent, expected: false)
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
            ("testDispatchWithMatchingAddress", testDispatchWithMatchingAddress),
            ("testDispatchWithMatchingAddresses", testDispatchWithMatchingAddresses),
            ("testDispatchWithNonMatchingSubComponents", testDispatchWithNonMatchingSubComponents),
            ("testDispatchWithNonMatchingRootComponents", testDispatchWithNonMatchingRootComponents),
            ("testDispatchWithNonMatchingAddresses", testDispatchWithNonMatchingAddresses)
        ]
    }
}
#endif
