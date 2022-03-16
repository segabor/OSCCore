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

        return withUnsafeBytes(of: self.bitPattern.bigEndian) {[Byte]($0)}
    }

    public var oscType: TypeTagValues {
        return self.isInfinite ? .INFINITUM_TYPE_TAG : .DOUBLE_TYPE_TAG
    }

    public init?(data: ArraySlice<Byte>) {
        let binary: [Byte] = [Byte](data)
        guard binary.count == MemoryLayout<Double>.size,
            let rawValue: UInt64 = UInt64(data: binary)
        else {
            return nil
        }

        self.init(bitPattern: rawValue)
    }

    public var packetSize: Int {
        return self.isInfinite ? 0 : MemoryLayout<UInt64>.size
    }
}
