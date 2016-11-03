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


/******************************/
/* OSC Packet Implementations */
/******************************/

extension String : OSCValue {
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



extension Float32 : OSCValue {
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


extension HasByteSwapping {
    public init?(data: ArraySlice<Byte>) {
        let binary : [Byte] = [Byte](data)
        if binary.count != MemoryLayout<Self>.size {
            return nil
        }
        
        self = binarytotype(binary, Self.self).byteSwapped
    }
}




extension Int64 : OSCValue {
    public var oscValue : [Byte] {
        let z = self.bigEndian
        return [Byte](typetobinary(z))
    }
    
    public var oscType : TypeTagValues { return .INT64_TYPE_TAG }
}

extension Int32 : OSCValue {
    public var oscValue : [Byte] {
        let z = self.bigEndian
        return [Byte](typetobinary(z))
    }
    
    public var oscType : TypeTagValues { return .INT32_TYPE_TAG }
}

// default Integers is converted to 32-bin integer for the sake of convenience
extension Int : OSCValue {
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


extension OSCTimeTag: OSCValue {
    
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



/*************************/
/* OSC Message structure */
/*************************/

public struct OSCMessage : OSCConvertible, Equatable {
    public let address: String
    public let args: [OSCValue]

    public init(address: String, args: [OSCValue]) {
        self.address = address
        self.args = args
    }
    
    public init(address: String, args: OSCValue...) {
        self.init(address: address, args: args)
    }
    
    public init?(data: ArraySlice<Byte>) {
        guard
            let address = String(data: data)
        else {
            return nil
        }


        var index = data.startIndex + paddedSize(address.utf8.count+1)
        var args = [OSCValue]()

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
        let osc_type_tags : String = String(args.map{$0.oscType.rawValue })
        
        // convert values to packets and collect them into a byte array
        let osc_args : [Byte] = args.map{$0.oscValue}.reduce([Byte](), +)

        // OSC Message := Address Pattern + Type Tag String + Arguments
        return address.oscValue
            + (","+osc_type_tags).oscValue
            + osc_args
    }

    /// Equatable
    public static func ==(lhs: OSCMessage, rhs: OSCMessage) -> Bool {
        return lhs.address == rhs.address && lhs.args == rhs.args
    }
}



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



public struct OSCBundle : OSCConvertible, Equatable {
    public let timetag : OSCTimeTag

    /// Bundle elements 
    public let content : [OSCConvertible]

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

    public init(timetag: OSCTimeTag, content: [OSCConvertible]) {
        self.timetag = timetag
        self.content = content
    }

    public init?(data: ArraySlice<Byte>) {
        /// Check the header
        /// - packet length must be at least 16 bytes ('#bundle' + timetag)
        guard
            data.count >= 16,
            data[0] == 0x23,
            let ts = OSCTimeTag(data: data[data.startIndex+8..<data.startIndex+16])
        else {
            return nil
        }

        var msgs = [OSCConvertible]()

        // Read up the content
        // from offset
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



    // Equatable
    public static func ==(lhs: OSCBundle, rhs: OSCBundle) -> Bool {
        return lhs.timetag == rhs.timetag && lhs.content == rhs.content
    }
}
