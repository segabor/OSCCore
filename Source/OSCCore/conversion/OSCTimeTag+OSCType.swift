//
//  OSCTimeTag+OSCType.swift
//  OSCCore
//
//  Created by Sebestyén Gábor on 2017. 11. 18..
//

import Foundation

internal func secondsToTuple(_ seconds: Double) -> (integer: UInt32, fraction: UInt32) {
    let fraction: UInt32 = UInt32( (seconds-floor(seconds))*4_294_967_296 )
    let integer: UInt32 = UInt32(seconds)

    return (integer: integer, fraction: fraction)
}

internal func tupleToSeconds(integer: UInt32, fraction: UInt32) -> Double {
    return Double(integer) + Double(fraction)/4_294_967_296

}

extension OSCTimeTag: OSCType {

    static let oscImmediateBytes: [Byte] = [0, 0, 0, 0, 0, 0, 0, 1]

    public var oscValue: [Byte] {

        switch self {
        case .immediate:
            return OSCTimeTag.oscImmediateBytes
        case .secondsSince1990(let seconds):

            // first convert double value to integer/fraction tuple
            let tuple = secondsToTuple(seconds)

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
            let seconds = tupleToSeconds(integer: secs, fraction: frac)

            self = .secondsSince1990(seconds)
        }
    }
}
