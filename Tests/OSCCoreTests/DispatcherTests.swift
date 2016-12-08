//
//  DispatcherTests.swift
//  OSCCore
//
//  Created by Gábor Sebestyén on 13/08/16.
//
//

@testable import OSCCore
import XCTest


class DispatcherTests : XCTestCase {
    func testMessageDispatch() {
        let mgr = SimpleMessageDispatcher()
        
        var flag = false
        
        mgr.register(pattern: "/test/*") {_ in 
            flag = true
        }

        mgr.dispatch(message: OSCMessage(address: "/test/1", args: 1234))
        
        XCTAssertTrue(flag)
    }
}


#if os(Linux)
    extension DispatcherTests {
        static var allTests: [(String, (DispatcherTests) -> () throws -> Void)] {
            return [
                ("testMessageDispatch", testMessageDispatch)
            ]
        }
    }
#endif
