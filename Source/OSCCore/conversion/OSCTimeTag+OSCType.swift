//
//  OSCTimeTag+OSCType.swift
//  OSCCore
//
//  Created by Sebestyén Gábor on 2017. 11. 18..
//

import Foundation

// MARK: Conversion between double and 64 bit fixed point values

internal extension Double {
    internal var fixPointValue: (integer: UInt32, fraction: UInt32) {
        let fraction: UInt32 = UInt32( (self-floor(self))*4_294_967_296 )
        let integer: UInt32 = UInt32(self)
        
        return (integer: integer, fraction: fraction)
    }

    internal init(integer: UInt32, fraction: UInt32) {
        self = Double(integer) + Double(fraction)/4_294_967_296
    }

}


// MARK: TimeTag type

extension OSCTimeTag: OSCType {

    static let oscImmediateBytes: [Byte] = [0, 0, 0, 0, 0, 0, 0, 1]

    public var oscValue: [Byte] {

        switch self {
        case .immediate:
            return OSCTimeTag.oscImmediateBytes
        case .secondsSince1900(let seconds):

            // first convert double value to integer/fraction tuple
            let tuple = seconds.fixPointValue

            // them make bytes out of them
            let b0 = typetobinary(tuple.integer)
            let b1 = typetobinary(tuple.fraction)

            return b0+b1
        }
    }

    public var oscType: TypeTagValues { return .TIME_TAG_TYPE_TAG }

    public init?<S: Collection>(data: S) where S.Iterator.Element == Byte {

        guard data.count == 8 else {
            return nil
        }

        if data.elementsEqual(OSCTimeTag.oscImmediateBytes) {
            self = .immediate
        } else {
            // integer/fraction tuple from byte stream
            let secs = binarytotype([Byte](data.prefix(4)), UInt32.self)
            let frac = binarytotype([Byte](data.suffix(4)), UInt32.self)

            // convert to double
            let seconds = Double(integer: secs, fraction: frac)

            self = .secondsSince1900(seconds)
        }
    }
}
