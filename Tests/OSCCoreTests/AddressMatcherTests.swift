//
//  AddressMatcherTests.swift
//  OSCCore
//
//  Created by Gábor Sebestyén on 13/08/16.
//
//

@testable import OSCCore
import XCTest


class AddressMatcherTests : XCTestCase {
    func testMatcherFunction() {
        
        XCTAssertTrue(matchComponent(address:"ablak", pattern:"ablak"))
        
        // print("false", matchComponent(address:"ablak", pattern:"abrak"))
        
        XCTAssertTrue(matchComponent(address:"ablak", pattern:"ab?ak"))
        
        XCTAssertTrue(matchComponent(address:"ablak", pattern:"ab*"))
        XCTAssertTrue(matchComponent(address:"ablak", pattern:"ab*k"))
        
        XCTAssertTrue(matchComponent(address:"ablak", pattern:"a{blak}"))
        XCTAssertTrue(matchComponent(address:"ablak", pattern:"a{blak,jto}"))
    }
}


#if os(Linux)
    extension AddressMatcherTests {
        static var allTests: [(String, (AddressMatcherTests) -> () throws -> Void)] {
            return [
                ("testMatcherFunction", testMatcherFunction)
            ]
        }
    }
#endif
