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

        var index: ArraySlice<Byte>.Index = data.startIndex + address.alignedSize

        guard data[index] == 0x2C,
            let typeTagLabels = String(data: data.suffix(from: index))
        else {
            return nil
        }

        index += typeTagLabels.alignedSize

        // NOTE: unrecognized type tag labels will be mapped as nils
        let typeTags: [TypeTagValues?] = typeTagLabels.map { TypeTagValues(rawValue: $0) }

        var tagIterator = typeTags.makeIterator()

        // skip first, nil value
        // no tag type associated to comma character
        _ = tagIterator.next()

        // process args
        guard let args = OSCMessage.parseArguments(&tagIterator, &index, data) else {
            return nil
        }

        self.init(address: address, args: args)
    }

    public var typeTags: String {
        var typeTags: [Character] = [","]
        args.forEach {
            if let arg = $0 {
                switch arg {
                case let collection as [OSCMessageArgument?]:
                    typeTags.append(contentsOf: collection.oscTypes.map {$0.rawValue})
                default:
                    typeTags.append(arg.oscType.rawValue)
                }
            } else {
                typeTags.append(TypeTagValues.NIL_TYPE_TAG.rawValue)
            }
        }

        return String(typeTags)
    }

    // OSC Message Prefix := Address Pattern + Type Tag String
    public var prefixOscValue: [Byte] {
        return address.oscValue! + typeTags.oscValue!
    }

    public var oscValue: [Byte]? {
        // convert values to packets and collect them into a byte array
        var argsBytes: [Byte] = [Byte]()
        args.forEach {
            if let bytes = $0?.oscValue {
                argsBytes += bytes
            }
        }

        // OSC Message := Address Pattern + Type Tag String + Arguments
        return prefixOscValue + argsBytes
    }

    public var packetSize: Int {
        return args
            .map { $0?.packetSize ?? 0 }
            .reduce(address.oscValue!.count + typeTags.oscValue!.count, { (acc: Int, size: Int) in acc + size })
    }

    public static func parseArguments( _ tagIterator: inout IndexingIterator<[TypeTagValues?]>, _ index: inout ArraySlice<Byte>.Index, _ data: ArraySlice<Byte>) -> [OSCMessageArgument?]? { // swiftlint:disable:this cyclomatic_complexity line_length function_body_length
        var args: [OSCMessageArgument?] = [OSCMessageArgument?]()

        while let possibleTag = tagIterator.next() {
            guard let tag = possibleTag else {
                // Encountered an unknown tag, abort
                return nil
            }

            switch tag {
            case .ARRAY_BEGIN_TYPE_TAG:
                guard let argArray: [OSCMessageArgument?] = parseArguments(&tagIterator, &index, data) else {
                    return nil
                }
                args.append(argArray as OSCMessageArgument)
                index += argArray.packetSize
            case .ARRAY_END_TYPE_TAG:
                // consume tag, return processed args
                return args
            case .STRING_TYPE_TAG:
                guard let val = String(data: data.suffix(from: index)) else {
                    return nil
                }
                args.append(val)
                index += val.packetSize
            case .SYMBOL_TYPE_TAG:
                guard let val = OSCSymbol(data: data.suffix(from: index)) else {
                    return nil
                }
                args.append(val)
                index += val.packetSize
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
                index += val.packetSize
            case .FLOAT_TYPE_TAG:
                guard let val = Float32(data: data[index..<index+4]) else {
                    return nil
                }
                args.append(val)
                index += val.packetSize
            case .DOUBLE_TYPE_TAG:
                guard let val = Double(data: data[index..<index+8]) else {
                    return nil
                }
                args.append(val)
                index += val.packetSize
            case .TIME_TAG_TYPE_TAG:
                // process the same way as Int64 but yield different Swift type
                guard let val = OSCTimeTag(data: data[index..<index+8]) else {
                    return nil
                }
                args.append(val)
                index += val.packetSize
            case .CHAR_TYPE_TAG:
                guard let val = Character(data: data[index..<index+4]) else {
                    return nil
                }
                args.append(val)
                index += val.packetSize
            case .RGBA_COLOR_TYPE_TAG:
                guard let val = RGBA(data: data[index..<index+4]) else {
                    return nil
                }
                args.append(val)
                index += val.packetSize
            case .MIDI_MESSAGE_TYPE_TAG:
                guard let val = MIDI(data: data[index..<index+4]) else {
                    return nil
                }
                args.append(val)
                index += val.packetSize
            case .BLOB_TYPE_TAG:
                guard let val = Data(data: data.suffix(from: index)) else {
                    return nil
                }
                args.append(val)
                index += val.packetSize
            case .NIL_TYPE_TAG:
                args.append(nil)
            case .TRUE_TYPE_TAG:
                args.append(true)
            case .FALSE_TYPE_TAG:
                args.append(false)
            case .INFINITUM_TYPE_TAG:
                args.append(Double.infinity)
            }
        }
        return args
    }
}
