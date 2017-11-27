//
//  OSCTimeTagTests.swift
//  OSCCorePackageDescription
//
//  Created by Sebestyén Gábor on 2017. 11. 27..
//

#if os(OSX) || os(iOS)
import Darwin
#elseif os(Linux)
import Glibc
#endif

@testable import OSCCore
import XCTest

class OSCTimeTagTests: XCTestCase {
    
    internal static let EPSILON: Double = 0.00001
    
    public func testImmediateTimeTagToDateConversion() {
        let timeTag: OSCTimeTag = OSCTimeTag.immediate

        let now: Date = Date()

        let ttDate: Date = timeTag.toDate()

        let delta: Double = ttDate.timeIntervalSinceReferenceDate - now.timeIntervalSinceReferenceDate

        XCTAssertTrue( fabs(delta) < OSCTimeTagTests.EPSILON )
    }
    
    public func testSecondsSince1900TimeTagConversion() {
        let testOSCSeconds = 1234.0
        
        let timeTag: OSCTimeTag = OSCTimeTag.secondsSince1900(testOSCSeconds)

        let expectedDate: Date =  Date(timeIntervalSince1970: OSCSecondsToInterval(testOSCSeconds))
        
        let ttDate = timeTag.toDate()
        
        let delta: Double = ttDate.timeIntervalSinceReferenceDate - expectedDate.timeIntervalSinceReferenceDate
        
        XCTAssertTrue( fabs(delta) < OSCTimeTagTests.EPSILON )
    }
}

#if os(Linux)
    extension OSCTimeTagTests {
        static var allTests: [(String, (OSCTimeTagTests) -> () throws -> Void)] {
            return [
                ("testImmediateTimeTagToDateConversion", testImmediateTimeTagToDateConversion),
                ("testSecondsSince1900TimeTagConversion", testSecondsSince1900TimeTagConversion)
            ]
        }
    }
#endif
