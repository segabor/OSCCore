//
//  timetag.swift
//  OSCCore
//
//  Created by Sebestyén Gábor on 2016. 10. 29..
//
//

import Foundation


// Time tags are represented by a 64 bit fixed point number.
// The first 32 bits specify the number of seconds since midnight on January 1, 1900,
// and the last 32 bits specify fractional parts of a second to a precision of about 200 picoseconds.
// This is the representation used by Internet NTP timestamps.
//
// The time tag value consisting of 63 zero bits followed by
// a one in the least signifigant bit is a special case meaning "immediately."

public struct TimeTag {
    /// number of seconds since midnight on January 1
    public let integer : UInt32
    
    /// fractional parts of a second
    public let fraction : UInt32

    public init(integer: UInt32, fraction: UInt32) {
        self.integer = integer
        self.fraction = fraction
    }
}


// MARK: Equatable
extension TimeTag : Equatable {
  public static func ==(lhs: TimeTag, rhs: TimeTag) -> Bool {
    return lhs.integer == rhs.integer && lhs.fraction == rhs.fraction
  }
}


// MARK: Immediate time tag support
public extension TimeTag {
    // TODO: Refactor this property to a kind of Optional type
    // like enum { case Immediate, Value(int,frac) }
    public var immediate : Bool {
        return integer == 0 && fraction == 1
    }

    // Default init creates immediate instance
    public init() {
        self.init(integer: 0, fraction: 1)
    }
}



// MARK: Floating point value conversion
public extension TimeTag {
  
    /// return floating point representation
    public var value : Double? {
        return self.immediate
            ? nil
            : Double(self.integer) + Double(self.fraction)/4_294_967_296
    }

    // Initialize with floating point value
    public init(value: Double) {
        let frac = UInt32( (value-floor(value))*4_294_967_296 )
        
        self.init(integer: UInt32(value), fraction: frac)
    }
}



// MARK: Date conversion
public extension TimeTag {
    /// seconds between 1900 and 1970
    static public let SecondsSince1900 : Double = 2208988800


    /// Return TimeTag value converted to Date
    public var time : Date {
        guard
            let fv = self.value
        else {
            return Date.distantPast
        }

        return Date(timeIntervalSince1970: fv-TimeTag.SecondsSince1900 )
    }
    
    public init(time : Date) {
        self.init(value: time.timeIntervalSince1970 + TimeTag.SecondsSince1900)
    }
}
