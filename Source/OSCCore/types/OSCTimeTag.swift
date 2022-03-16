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

// input: TimeInterval, seconds since 1970 (as defined in NSDate)
// output: seconds since 1900 (seconds counted in OSC)
@inline(__always)
internal func intervalToOSCSeconds(_ interval: TimeInterval) -> Double {
    return interval + OSCTimeTag.SecondsSince1900
}

@inline(__always)
internal func OSCSecondsToInterval(_ seconds: Double) -> TimeInterval {
    return seconds - OSCTimeTag.SecondsSince1900
}

public enum OSCTimeTag: Equatable {
    /// seconds between 1900 and 1970
    static internal let SecondsSince1900: Double = 2_208_988_800

    case immediate
    case secondsSince1900(Double) // seconds since January 1, 1900

    public static func withDelay(_ delay: TimeInterval) -> OSCTimeTag {
        return OSCTimeTag.secondsSince1900( intervalToOSCSeconds(Date.timeIntervalSinceReferenceDate + delay) )
    }

    public func toDate() -> Date {
        switch self {
        case .immediate:
            return Date()
        case .secondsSince1900(let oscSeconds):
            return Date(timeIntervalSince1970: OSCSecondsToInterval(oscSeconds))
        }
    }
}
