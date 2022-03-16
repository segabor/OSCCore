//
//  OSCSymbol+OSCType.swift
//  OSCCore
//
//  Created by Sebestyén Gábor on 2017. 12. 10..
//

import Foundation

extension OSCSymbol: OSCMessageArgument {
    public var oscType: TypeTagValues { .SYMBOL_TYPE_TAG }

    public var oscValue: [Byte]? { label.oscValue }

    public var alignedSize: Int { return label.alignedSize }

    var packetSize: Int { label.packetSize }

    public init?(data: ArraySlice<Byte>) {
        guard let label = String(data: data) else {
            return nil
        }

        self.init(label: label)
    }
}
