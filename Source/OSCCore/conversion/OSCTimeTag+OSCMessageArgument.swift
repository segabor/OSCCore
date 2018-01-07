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
        self = Double(integer) + (Double(fraction)/4_294_967_296)
    }

}

// MARK: TimeTag type

extension OSCTimeTag: OSCMessageArgument {

    static let oscImmediateBytes: [Byte] = [0, 0, 0, 0, 0, 0, 0, 1]

    public var oscValue: [Byte]? {

        switch self {
        case .immediate:
            return OSCTimeTag.oscImmediateBytes
        case .secondsSince1900(let seconds):

            // first convert double value to integer/fraction tuple
            let tuple = seconds.fixPointValue

            let timestamp: UInt64 = UInt64(tuple.integer) << 32 | UInt64(tuple.fraction)

            return timestamp.oscValue!
        }
    }

    public var oscType: TypeTagValues { return .TIME_TAG_TYPE_TAG }

    public var packetSize: Int {
        return MemoryLayout<UInt64>.size
    }

    public init?<S: Collection>(data: S) where S.Iterator.Element == Byte {

        guard data.count == 8 else {
            return nil
        }

        if data.elementsEqual(OSCTimeTag.oscImmediateBytes) {
            self = .immediate
        } else {
            guard let timestamp = UInt64(data: [Byte](data)) else {
                return nil
            }

            let secs = UInt32(timestamp >> 32)
            let frac = UInt32(timestamp & 0xFFFFFFFF)

            // convert to double
            let seconds = Double(integer: secs, fraction: frac)

            self = .secondsSince1900(seconds)
        }
    }
}
