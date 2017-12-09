//
//  Character+OSCConvertible.swift
//  OSCCore
//
//  Created by Sebestyén Gábor on 2017. 12. 09..
//

import Foundation

extension Character: OSCType {
    public var oscType: TypeTagValues {
        return TypeTagValues.CHAR_TYPE_TAG
    }

    public init?(data: ArraySlice<Byte>) {
        guard let rawValue = UInt32(data: data),
            let scalar = UnicodeScalar(rawValue)
        else {
            return nil
        }

        self.init(scalar)
    }

    public var oscValue: [Byte]? {
        let scalarArray = self.unicodeScalars
        return scalarArray[scalarArray.startIndex].value.oscValue
    }
}
