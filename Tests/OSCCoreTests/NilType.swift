//
//  NilType.swift
//  OSCCorePackageDescription
//
//  Created by Sebestyén Gábor on 2017. 12. 06..
//

import OSCCore

final class NilType : OSCType {
    
    public static let instance = NilType()
    
    init() {
    }

    var oscType: TypeTagValues {
        return .NIL_TYPE_TAG
    }

    var oscValue: [Byte]? {
        return nil
    }

    init?(data: ArraySlice<Byte>) {
        return nil
    }

    func isEqualTo(_ other: OSCConvertible) -> Bool {
        return other is NilType
    }
}
