//
//  MIDI.swift
//  OSCCore
//
//  Created by Sebestyén Gábor on 2017. 12. 30..
//

public struct MIDI {
    public let portId: UInt8
    public let status: UInt8
    public let data1: UInt8
    public let data2: UInt8

    public init(portId: UInt8, status: UInt8, data1: UInt8, data2: UInt8) {
        self.portId = portId
        self.status = status
        self.data1 = data1
        self.data2 = data2
    }
}
