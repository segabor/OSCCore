//
//  Double+OSCType.swift
//  OSCCore
//
//  Created by Sebestyén Gábor on 2017. 12. 29..
//

extension Double: OSCMessageArgument {
    public var oscValue: [Byte]? {
        guard self.isFinite else {
            return nil
        }

        let z = self.bitPattern.bigEndian
        return [Byte](typetobinary(z))
    }

    public var oscType: TypeTagValues {
        if self.isInfinite {
            return .INFINITUM_TYPE_TAG
        } else {
            return .DOUBLE_TYPE_TAG
        }
    }

    // custom init
    public init?(data: ArraySlice<Byte>) {
        let binary: [Byte] = [Byte](data)
        guard binary.count == MemoryLayout<Double>.size,
            let rawValue: UInt64 = UInt64(data: binary)
        else {
            return nil
        }

        self.init(bitPattern: rawValue)
    }
}
