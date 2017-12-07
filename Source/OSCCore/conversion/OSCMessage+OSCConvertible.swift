//
//  OSCMessage+OSCConvertible.swift
//  OSCCore
//
//  Created by Sebestyén Gábor on 2017. 11. 18..
//

import Foundation

extension OSCMessage: OSCConvertible {
    public init?(data: ArraySlice<Byte>) {
        guard let address = String(data: data) else {
            return nil
        }

        var index = data.startIndex + paddedSize(address.utf8.count+1)
        var args = [OSCType]()

        // find type tags string starting with comma (',')
        if data[index] == 0x2C,
            let typeTags = String(data: data.suffix(from: index+1)) {

            // process args list
            index += paddedSize(typeTags.utf8.count+2)
            for type_tag in typeTags {

                if let type: TypeTagValues = TypeTagValues(rawValue: type_tag) {
                    switch type {
                    case .STRING_TYPE_TAG:
                        guard let val = String(data: data.suffix(from: index)) else {
                            return nil
                        }
                        args.append(val)
                        index += paddedSize(val.utf8.count+1)
                    case .INT32_TYPE_TAG:
                        guard let val = Int32(data: data[index..<index+4]) else {
                            return nil
                        }
                        args.append(val)
                        index+=4
                    case .INT64_TYPE_TAG:
                        guard let val = Int64(data: data[index..<index+8]) else {
                            return nil
                        }
                        args.append(val)
                        index+=8
                    case .FLOAT_TYPE_TAG:
                        guard let val = Float32(data: data[index..<index+4]) else {
                            return nil
                        }
                        args.append(val)
                        index+=4
                    case .TIME_TAG_TYPE_TAG:
                        /// process the same way as Int64 but yield different Swift type
                        guard let val = OSCTimeTag(data: data[index..<index+8]) else {
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

    public var oscValue: [Byte]? {
        guard let addressBytes = address.oscValue,
            let typeTagBytes: [Byte] = (","+String(args.map {$0.oscType.rawValue })).oscValue
        else {
            return nil
        }

        // convert values to packets and collect them into a byte array
        var argsBytes: [Byte] = [Byte]()
        args.forEach {
            if let bytes = $0.oscValue {
                argsBytes += bytes
            }
        }

        // OSC Message := Address Pattern + Type Tag String + Arguments
        return addressBytes + typeTagBytes + argsBytes
    }

}
