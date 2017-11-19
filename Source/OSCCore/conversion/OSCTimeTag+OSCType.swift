//
//  OSCTimeTag+OSCType.swift
//  OSCCore
//
//  Created by Sebestyén Gábor on 2017. 11. 18..
//

import Foundation

extension OSCTimeTag: OSCType {

    static let oscImmediateBytes: [Byte] = [0, 0, 0, 0, 0, 0, 0, 1]

    public var oscValue: [Byte] {

        if self.timetag.immediate {
            return OSCTimeTag.oscImmediateBytes
        }

        let b0 = typetobinary(self.timetag.integer )
        let b1 = typetobinary(self.timetag.fraction )

        return b0+b1
    }

    public var oscType: TypeTagValues { return .TIME_TAG_TYPE_TAG }

    public init?<S: Collection>(data: S) where S.Iterator.Element == Byte, S.SubSequence.Iterator.Element == S.Iterator.Element {

        if data.count != 8 {
            return nil
        }

        if data.elementsEqual(OSCTimeTag.oscImmediateBytes) {
            self.timetag = TimeTag()
        } else {
            let secs = binarytotype([Byte](data.prefix(4)), UInt32.self)
            let frac = binarytotype([Byte](data.suffix(4)), UInt32.self)

            self.timetag = TimeTag(integer: secs, fraction: frac)
        }
    }
}
