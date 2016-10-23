///
///  defs.swift
///  OSCCore
///
///  Created by Gábor Sebestyén on 23/04/16.
///  Copyright © 2016 Gábor Sebestyén. All rights reserved.
///

public typealias Byte = UInt8


///
/// OSC Type Tag values
///
/// Enum borrowed from https://github.com/mkalten/reacTIVision/blob/master/ext/oscpack/osc/OscTypes.h
///
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



///
/// Objects implementing this protocol
/// can be converted to OSC packets
/// and back
///
/// Containers like OSC messages and
/// bundles implement this protocol
///
public protocol OSCConvertible {
    // return as byte sequence
    var oscValue : [Byte] { get }

    // construct OSC value from OSC packet
    init?<S : Collection>(data: S) where S.Iterator.Element == Byte, S.SubSequence.Iterator.Element == S.Iterator.Element

    // Custom function for Equatable
    func isEqualTo(_ other: OSCConvertible) -> Bool
}



///
/// Basic types adopting this protocol
/// can be converted to OSC value
///
public protocol OSCValue : OSCConvertible {
    // returns OSC type
    var oscType  : TypeTagValues { get }
}



///
/// Workaround for Equatable adoption
///
extension OSCConvertible where Self : Equatable {
    // otherObject could also be 'Any'
    public func isEqualTo(_ other: OSCConvertible) -> Bool {
        if let otherAsSelf = other as? Self {
            return otherAsSelf == self
        }
        return false
    }
}



/// Helper function to compare two OSC value arrays
public func ==(lhs: [OSCConvertible], rhs: [OSCConvertible]) -> Bool {
    if lhs.count == rhs.count {

        for pair in zip(lhs,rhs) {
            if pair.0.isEqualTo(pair.1) == false {
                  return false
            }
        }
        return true
    }

    return false
}
