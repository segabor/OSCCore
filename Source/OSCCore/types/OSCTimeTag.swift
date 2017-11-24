//
//  OSCTimeTag.swift
//  OSCCore
//
//  Created by Sebestyén Gábor on 2017. 11. 18..
//

import Foundation

// Time tags are represented by a 64 bit fixed point number.
// The first 32 bits specify the number of seconds since midnight on January 1, 1900,
// and the last 32 bits specify fractional parts of a second to a precision of about 200 picoseconds.
// This is the representation used by Internet NTP timestamps.
//
// The time tag value consisting of 63 zero bits followed by
// a one in the least signifigant bit is a special case meaning "immediately."

public enum OSCTimeTag: Equatable {
    /// seconds between 1900 and 1970
    static internal let SecondsSince1900: Double = 2208988800

    case immediate
    case secondsSince1990(TimeInterval) // seconds since January 1, 1900

    /// Equatable
    public static func == (lhs: OSCTimeTag, rhs: OSCTimeTag) -> Bool {
        if case .immediate = lhs, case .immediate = rhs {
            return true
        }
        if case .secondsSince1990(let lval) = lhs, case .secondsSince1990(let rval) = rhs {
            return lval == rval
        }
        return false
    }

    public func toDate() -> Date {
        switch self {
        case .immediate:
            return Date()
        case .secondsSince1990(let interval):
            return Date(timeIntervalSince1970: interval - OSCTimeTag.SecondsSince1900)
        }
    }
}
