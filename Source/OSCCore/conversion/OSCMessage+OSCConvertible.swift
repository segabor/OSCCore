//
//  OSCMessage+OSCConvertible.swift
//  OSCCore
//
//  Created by Sebestyén Gábor on 2017. 11. 18..
//

import Foundation

extension OSCMessage: OSCConvertible {
    public init?(data: ArraySlice<Byte>) { //swiftlint:disable:this cyclomatic_complexity
        guard let address = String(data: data) else {
            return nil
        }

        var index = data.startIndex + address.alignedSize
        var args = [OSCType?]()

        // find type tags string starting with comma (',')
        if data[index] == 0x2C,
            let typeTags = String(data: data.suffix(from: index)) {

            index += typeTags.alignedSize

            // process args list
            for type_tag in typeTags.suffix(from: typeTags.index(typeTags.startIndex, offsetBy: 1)) {
                if let type: TypeTagValues = TypeTagValues(rawValue: type_tag) {
                    switch type {
                    case .STRING_TYPE_TAG:
                        guard let val = String(data: data.suffix(from: index)) else {
                            return nil
                        }
                        args.append(val)
                        index += val.alignedSize
                    case .SYMBOL_TYPE_TAG:
                        guard let val = OSCSymbol(data: data.suffix(from: index)) else {
                            return nil
                        }
                        args.append(val)
                        index += val.alignedSize
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
                    case .CHAR_TYPE_TAG:
                        guard let val = Character(data: data[index..<index+4]) else {
                            return nil
                        }
                        args.append(val)
                        index+=4
                    case .NIL_TYPE_TAG:
                        args.append(nil)
                    case .TRUE_TYPE_TAG:
                        args.append(true)
                    case .FALSE_TYPE_TAG:
                        args.append(false)
                    default:
                        break
                    }
                }
            }
        }

        self.init(address: address, args: args)
    }

    public var oscValue: [Byte]? {
        var typeTags: [Character] = [","]
        args.forEach {
            typeTags.append($0?.oscType.rawValue ?? TypeTagValues.NIL_TYPE_TAG.rawValue)
        }

        // convert values to packets and collect them into a byte array
        var argsBytes: [Byte] = [Byte]()
        args.forEach {
            if let bytes = $0?.oscValue {
                argsBytes += bytes
            }
        }

        // OSC Message := Address Pattern + Type Tag String + Arguments
        return address.oscValue! + String(typeTags).oscValue! + argsBytes
    }

}
