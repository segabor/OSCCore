//
//  osc.swift
//  OSCCore
//
//  Created by Gábor Sebestyén on 23/04/16.
//  Copyright © 2016 Gábor Sebestyén. All rights reserved.
//

#if os(Linux)
import Glibc
#endif
import Foundation


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


// MARK: === OSC TimeTag Type ===


public struct OSCTimeTag: Equatable {
  public let timetag: TimeTag

  /// Create time tag with current time in millisecs
  public init() {
    self.timetag = TimeTag()
  }

  public init(timetag: TimeTag) {
    self.timetag = timetag
  }

  public init(withDelay delay: TimeInterval) {
    self.timetag = TimeTag(time: Date(timeIntervalSinceNow: delay))
  }



  /// Equatable
  public static func ==(lhs: OSCTimeTag, rhs: OSCTimeTag) -> Bool {
      return lhs.timetag == rhs.timetag
  }
}


// MARK: === OSC Message Type ===

public struct OSCMessage : Equatable {
  public let address: String
  public let args: [OSCType]

  public init(address: String, args: [OSCType]) {
    self.address = address
    self.args = args
  }
  
  public init(address: String, args: OSCType...) {
    self.init(address: address, args: args)
  }
  

  /// Equatable
  public static func ==(lhs: OSCMessage, rhs: OSCMessage) -> Bool {
    return lhs.address == rhs.address && lhs.args == rhs.args
  }
}


// MARK: === OSC Bundle Type ===

public struct OSCBundle : Equatable {
  public let timetag : OSCTimeTag

  /// Bundle elements 
  public let content : [OSCConvertible]

  public init(timetag: OSCTimeTag, content: [OSCConvertible]) {
    self.timetag = timetag
    self.content = content
  }

  // Equatable
  public static func ==(lhs: OSCBundle, rhs: OSCBundle) -> Bool {
    return lhs.timetag == rhs.timetag && lhs.content == rhs.content
  }
}
