//
//  conversion.swift
//  OSCCore
//
//  Created by Gábor Sebestyén on 2016. 12. 07..
//
//

#if os(Linux)
  import Glibc
#endif
import Foundation

// MARK: Definitions

public typealias Byte = UInt8


// MARK: Byte Swapping


// A simple hack to translate various Swift types to byte array
// Source: http://stackoverflow.com/questions/26953591/how-to-convert-a-double-into-a-byte-array-in-swift
func binarytotype <T> (_ value: [Byte], _: T.Type) -> T
{
  return value.withUnsafeBytes {
    $0.baseAddress!.load(as: T.self)
  }
}

func typetobinary <T> (_ value: T) -> [Byte]
{
  var mv = value
  return withUnsafeBytes(of: &mv) { Array($0) }
}



// Round up number to the nearest multiple of 4
@inline(__always) func paddedSize(_ size: Int) -> Int {
  return (size + 3) & ~0x03
}


//
/// Mark integer types supporting bytes swapping with a designated interface
//

public protocol HasByteSwapping {
  /// byte order if necessary.
  var bigEndian: Self { get }
  
  /// Returns the current integer with the byte order swapped.
  var byteSwapped: Self { get }
}

// following Swift types has built-in byte swapping support
extension Int : HasByteSwapping {}
extension Int16 : HasByteSwapping {}
extension Int32 : HasByteSwapping {}
extension Int64 : HasByteSwapping {}


extension HasByteSwapping {
  public init?(data: ArraySlice<Byte>) {
    let binary : [Byte] = [Byte](data)
    if binary.count != MemoryLayout<Self>.size {
      return nil
    }
    
    self = binarytotype(binary, Self.self).byteSwapped
  }
}



// MARK: Conversion protocol

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
  
  // construct OSC value from byte array
  init?(data: ArraySlice<Byte>)

  // Custom function for Equatable
  func isEqualTo(_ other: OSCConvertible) -> Bool
}

extension OSCConvertible {
  // construct type from byte array
  init?(data: Array<Byte>) {
    self.init(data: data[0..<data.count])
  }
}




///
/// Types adopting this protocol
/// can be converted to OSC value
///
public protocol OSCType : OSCConvertible {
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



// MARK: Convert Swift string

extension String : OSCType {
  public var oscValue : [Byte] {
    var bytes = self.utf8.map({ Byte( $0 ) })
    let fullSize =  paddedSize(bytes.count+1)
    let padding = fullSize - bytes.count
    if padding > 0 {
      bytes += [Byte](repeating: 0,  count: padding)
    }
    return bytes
  }
  
  public var oscType : TypeTagValues { return .STRING_TYPE_TAG }
  
  public init?(data: ArraySlice<Byte>) {
    guard
      let termIndex = data.index(of:0)
      else {
        return nil
    }
    
    self.init(bytes: data[data.startIndex..<termIndex], encoding: String.Encoding.utf8)
  }
}



// MARK: Convert Swift numeric types

extension Float32 : OSCType {
  public var oscValue : [Byte] {
    #if os(OSX)
      let z = CFConvertFloat32HostToSwapped(self).v
    #elseif os(Linux)
      let z = htonl(self.bitPattern)
    #endif
    return [Byte](typetobinary(z))
  }
  
  public var oscType : TypeTagValues { return .FLOAT_TYPE_TAG }
  
  // custom init
  public init?(data: ArraySlice<Byte>) {
    let binary : [Byte] = [Byte](data)
    if binary.count != MemoryLayout<Float32>.size {
      return nil
    }
    #if os(OSX)
      self = CFConvertFloatSwappedToHost(binarytotype(binary, CFSwappedFloat32.self))
    #elseif os(Linux)
      self = Float(bitPattern: ntohl(binarytotype(binary, UInt32.self)))
    #endif
  }
}



// Integer numbers have their special treatment ...
extension Int64 : OSCType {
  public var oscValue : [Byte] {
    let z = self.bigEndian
    return [Byte](typetobinary(z))
  }
  
  public var oscType : TypeTagValues { return .INT64_TYPE_TAG }
}

extension Int32 : OSCType {
  public var oscValue : [Byte] {
    let z = self.bigEndian
    return [Byte](typetobinary(z))
  }
  
  public var oscType : TypeTagValues { return .INT32_TYPE_TAG }
}

// default Integers is converted to 32-bin integer for the sake of convenience
extension Int : OSCType {
  public var oscValue : [Byte] {
    return Int32(self).oscValue
  }
  
  public var oscType : TypeTagValues { return .INT32_TYPE_TAG }
  
  public init?(data: ArraySlice<Byte>) {
    let binary : [Byte] = [Byte](data)
    if binary.count != MemoryLayout<Int32>.size {
      return nil
    }
    
    self = Int( binarytotype(binary, Int32.self).byteSwapped )
  }
}


// MARK: Time Tag conversion

extension OSCTimeTag: OSCType {
  
  static let oscImmediateBytes : [Byte] = [0, 0, 0, 0, 0, 0, 0, 1]
  
  public var oscValue: [Byte] {
    
    if self.timetag.immediate {
      return OSCTimeTag.oscImmediateBytes
    }
    
    let b0 = typetobinary(self.timetag.integer )
    let b1 = typetobinary(self.timetag.fraction )
    
    return b0+b1
  }
  
  public var oscType: TypeTagValues { return .TIME_TAG_TYPE_TAG }
  
  public init?<S: Collection>(data: S) where S.Iterator.Element == Byte, S.SubSequence.Iterator.Element == S.Iterator.Element {
    
    if data.count != 8 {
      return nil
    }
    
    if data.elementsEqual(OSCTimeTag.oscImmediateBytes) {
      self.timetag = TimeTag()
    } else {
      
      let secs = binarytotype([Byte](data.prefix(4)), UInt32.self)
      let frac = binarytotype([Byte](data.suffix(4)) , UInt32.self)
      
      self.timetag = TimeTag(integer: secs, fraction: frac)
    }
  }
}



// MARK: OSC message conversion

extension OSCMessage : OSCConvertible {
  public init?(data: ArraySlice<Byte>) {
    guard
      let address = String(data: data)
      else {
        return nil
    }
    
    
    var index = data.startIndex + paddedSize(address.utf8.count+1)
    var args = [OSCType]()
    
    // find type tags string starting with comma (',')
    if data[index] == 0x2C,
      let typeTags = String(data: data.suffix(from:index+1)) {
      
      // process args list
      index += paddedSize(typeTags.utf8.count+2)
      for type_tag in typeTags.characters {
        
        if let type : TypeTagValues = TypeTagValues(rawValue: type_tag) {
          switch type {
          case .STRING_TYPE_TAG:
            guard
              let val = String(data: data.suffix(from:index))
              else {
                return nil
            }
            args.append(val)
            index += paddedSize(val.utf8.count+1)
          case .INT32_TYPE_TAG:
            guard
              let val = Int32(data: data[index..<index+4])
              else {
                return nil
            }
            args.append(val)
            index+=4
          case .INT64_TYPE_TAG:
            guard
              let val = Int64(data: data[index..<index+8])
              else {
                return nil
            }
            args.append(val)
            index+=8
          case .FLOAT_TYPE_TAG:
            guard
              let val = Float32(data: data[index..<index+4])
              else {
                return nil
            }
            args.append(val)
            index+=4
          case .TIME_TAG_TYPE_TAG:
            /// process the same way as Int64 but yield different Swift type
            guard
              let val = OSCTimeTag(data: data[index..<index+8])
              else {
                return nil
            }
            args.append(val)
            index+=8
          default:
            break
          }
        }
      }
    }
    
    self.init(address: address, args: args)
  }
  
  public var oscValue : [Byte] {
    // align type letters to one string, starting with a comma character
    let typeTags : String = String(args.map{$0.oscType.rawValue })
    
    // convert values to packets and collect them into a byte array
    let argsArray : [Byte] = args.map{$0.oscValue}.reduce([Byte](), +)
    
    // OSC Message := Address Pattern + Type Tag String + Arguments
    return address.oscValue
      + (","+typeTags).oscValue
      + argsArray
  }
  
}



// MARK: OSC bundle conversion

/// Iterator that yields bundle elements as slices
struct OSCBundleElementIterator : IteratorProtocol {
  let bytes : ArraySlice<Byte>
  var index : Int
  
  init(_ bytes: ArraySlice<Byte>) { self.bytes = bytes; index = bytes.startIndex }
  
  mutating func next() -> ArraySlice<Byte>? {
    if index < bytes.endIndex, let len = Int(data: bytes[index..<(index+4)]) {
      let d = bytes[index+4..<index+4+len]
      index += 4+len
      return d
    } else {
      return nil
    }
  }
}


extension OSCBundle : OSCConvertible {
  public var oscValue : [Byte] {
    var result = [Byte]()
    
    // write out head first
    result += "#bundle".oscValue
    result += timetag.oscValue
    
    /// asemble osc elements: size then content
    content.forEach { msg in
      let v = msg.oscValue
      result += Int32(v.count).oscValue
      result += v
    }
    return result
  }
  
  public init?(data: ArraySlice<Byte>) {
    // Check the header
    // - packet length must be at least 16 bytes ('#bundle' + timetag)
    guard
      data.count >= 16,
      data[0] == 0x23,
      let ts = OSCTimeTag(data: data[data.startIndex+8..<data.startIndex+16])
      else {
        return nil
    }
    
    var msgs = [OSCConvertible]()
    
    // Read up content
    var it = OSCBundleElementIterator(data[data.startIndex+16..<data.endIndex] )
    while let chunk = it.next() {
      if let msg = OSCMessage(data: chunk ) {
        msgs.append(msg)
      } else if let bnd = OSCBundle(data: chunk) {
        msgs.append(bnd)
      }
    }
    
    // init object state
    self.init(timetag: ts, content: msgs)
  }
}



// MARK: decode message packets from byte stream

public typealias MessageDecoder = ([Byte]) -> OSCConvertible?

public func decodeBytes(_ rawData: [Byte]) -> OSCConvertible? {
  if let msg = OSCMessage(data: rawData ) {
    return msg
  } else if let bndl = OSCBundle(data: rawData) {
    return bndl
  }
  
  return nil
}
