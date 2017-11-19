//
//  TimeTag.swift
//  OSCCore
//
//  Created by Sebestyén Gábor on 2017. 11. 17..
//

import Foundation

// Time tags are represented by a 64 bit fixed point number.
// The first 32 bits specify the number of seconds since midnight on January 1, 1900,
// and the last 32 bits specify fractional parts of a second to a precision of about 200 picoseconds.
// This is the representation used by Internet NTP timestamps.
//
// The time tag value consisting of 63 zero bits followed by
// a one in the least signifigant bit is a special case meaning "immediately."

internal struct TimeTag: Equatable {
    /// number of seconds since midnight on January 1
    let integer: UInt32

    /// fractional parts of a second
    let fraction: UInt32

    /// Equatable
    public static func == (lhs: TimeTag, rhs: TimeTag) -> Bool {
        return lhs.integer == rhs.integer && lhs.fraction == rhs.fraction
    }
}

// MARK: Immediate time tag support
internal extension TimeTag {
    // TODO: Refactor this property to a kind of Optional type
    // like enum { case Immediate, Value(int,frac) }
    internal var immediate: Bool {
        return integer == 0 && fraction == 1
    }

    // Default init creates immediate instance
    internal init() {
        self.init(integer: 0, fraction: 1)
    }
}

// MARK: Floating point value conversion
internal extension TimeTag {
    /// return floating point representation
    internal var value: Double? {
        return self.immediate
            ? nil
            : Double(self.integer) + Double(self.fraction)/4_294_967_296
    }

    // Initialize with floating point value
    internal init(value: Double) {
        let frac = UInt32( (value-floor(value))*4_294_967_296 )

        self.init(integer: UInt32(value), fraction: frac)
    }
}

// MARK: Date conversion
internal extension TimeTag {
    /// seconds between 1900 and 1970
    static internal let SecondsSince1900: Double = 2208988800

    /// Return TimeTag value converted to Date
    internal var time: Date {
        guard let fv = self.value else {
            return Date.distantPast
        }

        return Date(timeIntervalSince1970: fv-TimeTag.SecondsSince1900 )
    }

    internal init(time: Date) {
        self.init(value: time.timeIntervalSince1970 + TimeTag.SecondsSince1900)
    }
}
