//
//  TypeTagValues.swift
//  OSCCore
//
//  Created by Sebestyén Gábor on 2017. 11. 18..
//

///
/// OSC Type Tag values
///
/// Enum borrowed from https://github.com/mkalten/reacTIVision/blob/master/ext/oscpack/osc/OscTypes.h
///
public enum TypeTagValues: Character {
    case TRUE_TYPE_TAG = "T" // swiftlint:disable:this identifier_name
    case FALSE_TYPE_TAG = "F" // swiftlint:disable:this identifier_name
    case NIL_TYPE_TAG = "N" // swiftlint:disable:this identifier_name
    case INFINITUM_TYPE_TAG = "I" // swiftlint:disable:this identifier_name
    case INT32_TYPE_TAG = "i" // swiftlint:disable:this identifier_name
    case FLOAT_TYPE_TAG = "f" // swiftlint:disable:this identifier_name
    case CHAR_TYPE_TAG = "c" // swiftlint:disable:this identifier_name
    case RGBA_COLOR_TYPE_TAG = "r" // swiftlint:disable:this identifier_name
    case MIDI_MESSAGE_TYPE_TAG = "m" // swiftlint:disable:this identifier_name
    case INT64_TYPE_TAG = "h" // swiftlint:disable:this identifier_name
    case TIME_TAG_TYPE_TAG = "t" // swiftlint:disable:this identifier_name
    case DOUBLE_TYPE_TAG = "d" // swiftlint:disable:this identifier_name
    case STRING_TYPE_TAG = "s" // swiftlint:disable:this identifier_name
    case SYMBOL_TYPE_TAG = "S" // swiftlint:disable:this identifier_name
    case BLOB_TYPE_TAG = "b" // swiftlint:disable:this identifier_name
    case ARRAY_BEGIN_TYPE_TAG = "[" // swiftlint:disable:this identifier_name
    case ARRAY_END_TYPE_TAG = "]" // swiftlint:disable:this identifier_name
}
