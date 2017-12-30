//
//  RGBA+OSCType.swift
//  OSCCore
//
//  Created by Sebestyén Gábor on 2017. 12. 29..
//

import Foundation

extension RGBA: OSCMessageArgument {

    public init?(data: ArraySlice<Byte>) {
        let binary: [Byte] = [Byte](data)
        guard let flatValue = UInt32(data: binary) else {
            return nil
        }

        self.init(red: UInt8(flatValue >> 24), green: UInt8( (flatValue >> 16) & 0xFF), blue: UInt8( (flatValue >> 8) & 0xFF), alpha: UInt8(flatValue & 0xFF))
    }

    public var oscType: TypeTagValues {
        return .RGBA_COLOR_TYPE_TAG
    }

    public var oscValue: [Byte]? {
        let r: UInt32 = UInt32(self.red)
        let g: UInt32 = UInt32(self.green)
        let b: UInt32 = UInt32(self.blue)
        let a: UInt32 = UInt32(self.alpha)
        let flatValue: UInt32 = r << 24 | g << 16 | b << 8 | a

        return flatValue.oscValue
    }
}
