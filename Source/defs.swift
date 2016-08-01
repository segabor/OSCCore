//
//  defs.swift
//  OSCCore
//
//  Created by Gábor Sebestyén on 23/04/16.
//  Copyright © 2016 Gábor Sebestyén. All rights reserved.
//

public typealias Byte = UInt8

public typealias ParsedMessage = (address: String, args: [OSCValue])


/*
 * OSC Type Tag values
 *
 * Enum borrowed from https://github.com/mkalten/reacTIVision/blob/master/ext/oscpack/osc/OscTypes.h
 */
public enum TypeTagValues : Character {
    case TRUE_TYPE_TAG = "T"
    case FALSE_TYPE_TAG = "F"
    case NIL_TYPE_TAG = "N"
    case INFINITUM_TYPE_TAG = "I"
    case INT32_TYPE_TAG = "i"
    case FLOAT_TYPE_TAG = "f"
    case CHAR_TYPE_TAG = "c"
    case RGBA_COLOR_TYPE_TAG = "r"
    case MIDI_MESSAGE_TYPE_TAG = "m"
    case INT64_TYPE_TAG = "h"
    case TIME_TAG_TYPE_TAG = "t"
    case DOUBLE_TYPE_TAG = "d"
    case STRING_TYPE_TAG = "s"
    case SYMBOL_TYPE_TAG = "S"
    case BLOB_TYPE_TAG = "b"
    case ARRAY_BEGIN_TYPE_TAG = "["
    case ARRAY_END_TYPE_TAG = "]"
}



/*
 * Enable conversion between Swift types and OSC packets
 */
public protocol OSCValue {
    // convert value to OSC packet
    var oscValue : [Byte] { get }
    // returns OSC type
    var oscType  : TypeTagValues { get }
    // construct value from OSC packet
    init?<S : Collection>(data: S) where S.Iterator.Element == Byte, S.SubSequence.Iterator.Element == S.Iterator.Element

    // Custom equality check
    func isEqualTo(_ other: OSCValue) -> Bool
}

// Workaround for Equatable adoption
//
extension OSCValue where Self : Equatable {
    // otherObject could also be 'Any'
    public func isEqualTo(_ other: OSCValue) -> Bool {
        if let otherAsSelf = other as? Self {
            return otherAsSelf == self
        }
        return false
    }
}
