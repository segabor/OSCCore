//
//  Array+OSCMessageArgument.swift
//  OSCCore
//
//  Created by Sebestyén Gábor on 2018. 01. 04..
//

import Foundation

// add default conformance
extension Array: OSCMessageArgument, OSCMessageArgumentCollection {
    public init?(data: ArraySlice<Byte>) {
        // DO NOT USE THIS METHOD!!
        return nil
    }

    public var oscType: TypeTagValues {
        return .ARRAY_BEGIN_TYPE_TAG
    }

    public var oscTypes: [TypeTagValues] {
        var typeTags: [TypeTagValues] = [TypeTagValues.ARRAY_BEGIN_TYPE_TAG]
        self.forEach { (elem) -> Void in
            switch elem {
            case let argCollection as OSCMessageArgumentCollection:
                typeTags.append(contentsOf: argCollection.oscTypes)
            case let arg as OSCMessageArgument:
                typeTags.append(arg.oscType)
            default:
                typeTags.append(TypeTagValues.NIL_TYPE_TAG)
            }
        }
        typeTags.append(.ARRAY_END_TYPE_TAG)
        return typeTags
    }

    public var oscValue: [Byte]? {
        var bytes: [Byte] = [Byte]()

        self.forEach { (elem) -> Void in
            if let arg = elem as? OSCMessageArgument,
                let argBytes = arg.oscValue {
                bytes += argBytes
            }
        }

        return bytes
    }

    public var packetSize: Int {
        var total = 0
        self.forEach { (elem) -> Void in
            if let z = elem as? OSCMessageArgument {
                total += z.packetSize
            }
        }
        return total
    }
}
