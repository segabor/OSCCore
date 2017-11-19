//
//  OSCBundle.swift
//  OSCCore
//
//  Created by Sebestyén Gábor on 2017. 11. 18..
//

import Foundation

public struct OSCBundle: Equatable {
    public let timetag: OSCTimeTag

    /// Bundle elements
    public let content: [OSCConvertible]

    public init(timetag: OSCTimeTag, content: [OSCConvertible]) {
        self.timetag = timetag
        self.content = content
    }

    /// Equatable
    public static func == (lhs: OSCBundle, rhs: OSCBundle) -> Bool {
        return lhs.timetag == rhs.timetag && lhs.content == rhs.content
    }
}
