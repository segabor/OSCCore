//
//  OSCBundle.swift
//  OSCCore
//
//  Created by Sebestyén Gábor on 2017. 11. 18..
//

import Foundation

public struct OSCBundle {
    public let timetag: OSCTimeTag

    /// Bundle elements
    public let content: [OSCConvertible]

    public init(timetag: OSCTimeTag, content: [OSCConvertible]) {
        self.timetag = timetag
        self.content = content
    }
}
