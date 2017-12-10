//
//  OSCSymbol+OSCType.swift
//  OSCCore
//
//  Created by Sebestyén Gábor on 2017. 12. 10..
//

import Foundation

extension OSCSymbol: OSCType {
    public var oscType: TypeTagValues {
        return TypeTagValues.SYMBOL_TYPE_TAG
    }

    public var oscValue: [Byte]? {
        return label.oscValue
    }

    public var alignedSize: Int {
        return label.alignedSize
    }

    public init?(data: ArraySlice<Byte>) {
        guard let label = String(data: data) else {
            return nil
        }

        self.init(label: label)
    }
}
