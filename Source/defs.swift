//
//  defs.swift
//  testapp
//
//  Created by Gábor Sebestyén on 23/04/16.
//  Copyright © 2016 Gábor Sebestyén. All rights reserved.
//

typealias Byte = UInt8



/*
 * OSC Type Tag values
 *
 * Enum borrowed from https://github.com/mkalten/reacTIVision/blob/master/ext/oscpack/osc/OscTypes.h
 */
enum TypeTagValues : Character {
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
protocol OSCValue {
    // convert value to OSC packet
    var oscValue : [Byte] { get }
    // returns OSC type
    var oscType  : TypeTagValues { get }
    // construct value from OSC packet
    init?<S : CollectionType where S.Generator.Element == Byte, S.SubSequence.Generator.Element == S.Generator.Element>(data: S)
}
