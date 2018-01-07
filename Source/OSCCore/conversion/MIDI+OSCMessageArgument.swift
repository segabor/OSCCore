//
//  MIDI+OSCType.swift
//  OSCCore
//
//  Created by Sebestyén Gábor on 2017. 12. 30..
//

extension MIDI: OSCMessageArgument {

    public init?(data: ArraySlice<Byte>) {
        let binary: [Byte] = [Byte](data)
        guard let flatValue = UInt32(data: binary) else {
            return nil
        }

        self.init(portId: UInt8(flatValue >> 24), status: UInt8( (flatValue >> 16) & 0xFF), data1: UInt8( (flatValue >> 8) & 0xFF), data2: UInt8(flatValue & 0xFF))
    }

    public var oscType: TypeTagValues {
        return .MIDI_MESSAGE_TYPE_TAG
    }

    public var oscValue: [Byte]? {
        let portId: UInt32 = UInt32(self.portId)
        let statusByte: UInt32 = UInt32(self.status)
        let data1: UInt32 = UInt32(self.data1)
        let data2: UInt32 = UInt32(self.data2)
        let flatValue: UInt32 = portId << 24 | statusByte << 16 | data1 << 8 | data2

        return flatValue.oscValue
    }

    public var packetSize: Int {
        return MemoryLayout<UInt32>.size
    }
}
