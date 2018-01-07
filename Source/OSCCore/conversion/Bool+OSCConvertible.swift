//
//  Bool+OSCConvertible.swift
//  OSCCorePackageDescription
//
//  Created by Sebestyén Gábor on 2017. 12. 08..
//

import Foundation

extension Bool: OSCMessageArgument {
    public var oscType: TypeTagValues {
        return self == true ? TypeTagValues.TRUE_TYPE_TAG : TypeTagValues.FALSE_TYPE_TAG
    }

    public init?(data: ArraySlice<Byte>) {
        fatalError("Unsupported initializer")
    }

    public var oscValue: [Byte]? {
        return nil
    }

    public var packetSize: Int {
        return 0
    }
}
