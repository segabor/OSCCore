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
 
    public init?<S : Collection>(data: S) where S.Iterator.Element == Byte, S.SubSequence.Iterator.Element == S.Iterator.Element {
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
    public init?<S : Collection>(data: S) where S.Iterator.Element == Byte, S.SubSequence.Iterator.Element == S.Iterator.Element {
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
    public init?<S : Collection>(data: S) where S.Iterator.Element == Byte, S.SubSequence.Iterator.Element == S.Iterator.Element {
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

    public init?<S : Collection>(data: S) where S.Iterator.Element == Byte, S.SubSequence.Iterator.Element == S.Iterator.Element {
        let binary : [Byte] = [Byte](data)
        if binary.count != MemoryLayout<Int32>.size {
            return nil
        }

        self = Int( binarytotype(binary, Int32.self).byteSwapped )
    }
}


public struct OSCTimeTag: OSCValue, Equatable {
    public let value: Int64

    public var oscValue: [Byte] { return value.oscValue }

    public var oscType: TypeTagValues { return .TIME_TAG_TYPE_TAG }


    public init(_ value: Int64) {
        self.value = value
    }

    public init?<S: Collection>(data: S) where S.Iterator.Element == Byte, S.SubSequence.Iterator.Element == S.Iterator.Element {
        guard
            let intValue = Int64(data: data)
        else {
            return nil
        }

        self.value = intValue
    }

    /// Equatable
    public static func ==(lhs: OSCTimeTag, rhs: OSCTimeTag) -> Bool {
        return lhs.value == rhs.value
    }
}



/*************************/
/* OSC Message structure */
/*************************/

public class OSCMessage {
    public let data : [Byte]

    public init(address: String, args: OSCValue...) {
        data = OSCMessage.convert(address, args)
    }

    public init(address: String) {
        data = OSCMessage.convert(address, [])
    }
    
    public init(data: [Byte]) {
        self.data = data
    }

    // convert message into OSC message
    static func convert(_ address: String, _ args: [OSCValue]) -> [Byte] {
        // align type letters to one string, starting with a comma character
        let osc_type_tags : String = String(args.map{$0.oscType.rawValue })
        
        // convert values to packets and collect them into a byte array
        let osc_args : [Byte] = args.map{$0.oscValue}.reduce([Byte](), +)

        // OSC Message := Address Pattern + Type Tag String + Arguments
        return address.oscValue
            + (","+osc_type_tags).oscValue
            + osc_args
    }

    /*
     * Get OSC message from packet stream
     */
    public func parse() -> ParsedMessage? {
        let commabuf = [Byte](",".utf8)
        var index = data.startIndex
        
        guard
            let address = String(data: data)
        else {
            return nil
        }
        
        index = paddedSize(address.utf8.count+1)
        
        // find type tags string
        
        guard
            data[index] == commabuf[0],
            let _type_tags = String(data: data.suffix(from:index+1))
        else {
            return (address: address, args:[])
        }
        
        // process args list
        index += paddedSize(_type_tags.utf8.count+2)

        var args = [OSCValue]()
        for type_tag in _type_tags.characters {
            
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
                        let val = Int32(data: data[index..<(index+4)])
                    else {
                        return nil
                    }
                    args.append(val)
                    index+=4
                case .INT64_TYPE_TAG:
                    guard
                        let val = Int64(data: data[index..<(index+8)])
                    else {
                        return nil
                    }
                    args.append(val)
                    index+=8
                case .FLOAT_TYPE_TAG:
                    guard
                        let val = Float32(data: data[index..<(index+4)])
                    else {
                        return nil
                    }
                    args.append(val)
                    index+=4
                case .TIME_TAG_TYPE_TAG:
                    /// process the same way as Int64 but yield different Swift type
                    guard
                        let val = OSCTimeTag(data: data[index..<(index+8)])
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
        
        return (address: address, args: args)
    }
}
