//
//  String+OSCType.swift
//  OSCCore
//
//  Created by Sebestyén Gábor on 2017. 11. 19..
//

extension String {
    public var alignedSize: Int {
        // include \0 terminator character
        let cStringSize = self.utf8.count+1
        return (cStringSize + 3) & ~0x03
    }
}

extension String: OSCMessageArgument {
    public var oscValue: [Byte]? {
        var bytes = self.utf8.map {Byte($0)}
        let fullSize = alignedSize
        let padding = fullSize - bytes.count
        if padding > 0 {
            bytes += [Byte](repeating: 0, count: padding)
        }
        return bytes
    }

    public var oscType: TypeTagValues { return .STRING_TYPE_TAG }

    public init?(data: ArraySlice<Byte>) {
        guard let termIndex = data.index(of: 0) else {
            return nil
        }

        self.init(bytes: data[data.startIndex..<termIndex], encoding: String.Encoding.utf8)
    }
}
