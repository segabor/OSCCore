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

        let red = UInt8(flatValue >> 24)
        let green = UInt8( (flatValue >> 16) & 0xFF)
        let blue = UInt8( (flatValue >> 8) & 0xFF)
        let alpha = UInt8(flatValue & 0xFF)

        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }

    public var oscType: TypeTagValues {
        return .RGBA_COLOR_TYPE_TAG
    }

    public var oscValue: [Byte]? {
        let red: UInt32 = UInt32(self.red)
        let green: UInt32 = UInt32(self.green)
        let blue: UInt32 = UInt32(self.blue)
        let alpha: UInt32 = UInt32(self.alpha)
        let flatValue: UInt32 = red << 24 | green << 16 | blue << 8 | alpha

        return flatValue.oscValue
    }

    public var packetSize: Int {
        return MemoryLayout<UInt32>.size
    }
}
