//
//  String+OSCType.swift
//  OSCCore
//
//  Created by Sebestyén Gábor on 2017. 11. 19..
//

extension String: OSCMessageArgument {
    public var oscValue: [Byte]? {
        var oscBytes = self.utf8.map {Byte($0)}
        let packetSize = self.alignedSize
        let padding = packetSize - oscBytes.count
        if padding > 0 {
            oscBytes += [Byte](repeating: 0, count: padding)
        }

        return oscBytes
    }

    public var oscType: TypeTagValues { return .STRING_TYPE_TAG }

    public var packetSize: Int { self.alignedSize }

    public init?(data: ArraySlice<Byte>) {
        guard let termIndex = data.firstIndex(of: 0) else {
            return nil
        }

        self.init(bytes: data[data.startIndex..<termIndex], encoding: String.Encoding.utf8)
    }
}
