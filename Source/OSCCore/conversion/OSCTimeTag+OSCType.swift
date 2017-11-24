//
//  OSCTimeTag+OSCType.swift
//  OSCCore
//
//  Created by Sebestyén Gábor on 2017. 11. 18..
//

import Foundation

// MARK: Conversion between double and 64 bit fixed point values

internal func convertDoubleTo64bitFixPoint(_ seconds: Double) -> (integer: UInt32, fraction: UInt32) {
    let fraction: UInt32 = UInt32( (seconds-floor(seconds))*4_294_967_296 )
    let integer: UInt32 = UInt32(seconds)

    return (integer: integer, fraction: fraction)
}

internal func conver64bitFixPointToDouble(integer: UInt32, fraction: UInt32) -> Double {
    return Double(integer) + Double(fraction)/4_294_967_296

}

// MARK: TimeTag type

extension OSCTimeTag: OSCType {

    static let oscImmediateBytes: [Byte] = [0, 0, 0, 0, 0, 0, 0, 1]

    public var oscValue: [Byte] {

        switch self {
        case .immediate:
            return OSCTimeTag.oscImmediateBytes
        case .secondsSince1990(let seconds):

            // first convert double value to integer/fraction tuple
            let tuple = convertDoubleTo64bitFixPoint(seconds)

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
            let seconds = conver64bitFixPointToDouble(integer: secs, fraction: frac)

            self = .secondsSince1990(seconds)
        }
    }
}
