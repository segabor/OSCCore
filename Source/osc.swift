//
//  osc.swift
//  OSCCore
//
//  Created by Gábor Sebestyén on 23/04/16.
//  Copyright © 2016 Gábor Sebestyén. All rights reserved.
//

import Foundation


/******************************/
/* OSC Packet Implementations */
/******************************/

extension String : OSCValue {
    var oscValue : [Byte] {
        var bytes = self.utf8.map({ Byte( $0 ) })
        let fullSize =  paddedSize(bytes.count+1)
        let padding = fullSize - bytes.count
        if padding > 0 {
            bytes += [Byte](repeating: 0,  count: padding)
        }
        return bytes
    }
    
    var oscType : TypeTagValues { return .STRING_TYPE_TAG }
 
    init?<S : Collection where S.Iterator.Element == Byte, S.SubSequence.Iterator.Element == S.Iterator.Element>(data: S) {
        guard
            let termIndex = data.index(of:0)
        else {
            return nil
        }

        self.init(bytes: data[data.startIndex..<termIndex], encoding: NSUTF8StringEncoding)
    }
}



extension Float32 : OSCValue {
    var oscValue : [Byte] {
        let z = CFConvertFloat32HostToSwapped(self).v
        return [Byte](typetobinary(z).prefix(4))
    }
    
    var oscType : TypeTagValues { return .FLOAT_TYPE_TAG }
    
    // custom init
    init?<S : Collection where S.Iterator.Element == Byte, S.SubSequence.Iterator.Element == S.Iterator.Element>(data: S) {
        guard
            let binary : [Byte] = [Byte](data)
            where binary.count == sizeof(self.dynamicType)
        else {
            return nil
        }

        self = CFConvertFloatSwappedToHost(binarytotype(binary, CFSwappedFloat32.self))
    }
}



// Integer numbers have their special treatment ...


extension HasByteSwapping {
    init?<S : Collection where S.Iterator.Element == Byte, S.SubSequence.Iterator.Element == S.Iterator.Element>(data: S) {
        guard
            let binary : [Byte] = [Byte](data)
            where binary.count == sizeof(Self)
        else {
            return nil
        }
        
        self = binarytotype(binary, Self.self).byteSwapped
    }
}




extension Int64 : OSCValue {
    var oscValue : [Byte] {
        let z = self.bigEndian
        return [Byte](typetobinary(z).prefix(sizeof(self.dynamicType)))
    }
    
    var oscType : TypeTagValues { return .INT64_TYPE_TAG }
}

extension Int32 : OSCValue {
    var oscValue : [Byte] {
        let z = self.bigEndian
        return [Byte](typetobinary(z).prefix(sizeof(self.dynamicType)))
    }
    
    var oscType : TypeTagValues { return .INT32_TYPE_TAG }
}

// default Integers is converted to 32-bin integer for the sake of convenience
extension Int : OSCValue {
    var oscValue : [Byte] {
        return Int32(self).oscValue
    }
    
    var oscType : TypeTagValues { return .INT32_TYPE_TAG }

    init?<S : Collection where S.Iterator.Element == Byte, S.SubSequence.Iterator.Element == S.Iterator.Element>(data: S) {
        guard
            let binary : [Byte] = [Byte](data)
            where binary.count == sizeof(Int32.self)
        else {
            return nil
        }

        self = Int( binarytotype(binary, Int32.self).byteSwapped )
    }
}





/*************************/
/* OSC Message structure */
/*************************/

class OSCMessage {
    let data : [Byte]
    
    init(address: String, args: OSCValue...) {
        data = OSCMessage.convert(address, args)
    }
    
    init(data: [Byte]) {
        self.data = data
    }

    // convert message into OSC message
    static func convert(_ address: String, _ args: [OSCValue]) -> [Byte] {
        // align type letters to one string, starting with a comma character
        let osc_type_tags : String = String(args.map{$0.oscType.rawValue })
        
        // convert values to packets and collect them into a byte array
        let osc_args : [Byte] = args.map{$0.oscValue}.reduce([Byte](), combine: +)

        // OSC Message := Address Pattern + Type Tag String + Arguments
        return address.oscValue
            + (","+osc_type_tags).oscValue
            + osc_args
    }

    /*
     * Get OSC message from packet stream
     */
    func parse() -> (address: String, args: [OSCValue])? {
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
                default:
                    break
                }
            }
        }
        
        return (address: address, args: args)
    }
}
