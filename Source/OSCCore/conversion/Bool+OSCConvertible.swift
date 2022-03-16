//
//  Bool+OSCConvertible.swift
//  OSCCorePackageDescription
//
//  Created by Sebestyén Gábor on 2017. 12. 08..
//

import Foundation

extension Bool: OSCMessageArgument {
    public var oscType: TypeTagValues {
        return self == true ? .TRUE_TYPE_TAG : .FALSE_TYPE_TAG
    }

    public init?(data: ArraySlice<Byte>) {
        fatalError("Unsupported initializer")
    }

    public var oscValue: [Byte]? { nil }

    public var packetSize: Int { 0 }
}
