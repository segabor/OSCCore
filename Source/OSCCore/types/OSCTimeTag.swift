//
//  OSCTimeTag.swift
//  OSCCore
//
//  Created by Sebestyén Gábor on 2017. 11. 18..
//

import Foundation.NSDate

public struct OSCTimeTag: Equatable {
    internal let timetag: TimeTag

    /// Create time tag with current time in millisecs
    public init() {
        self.timetag = TimeTag()
    }

    internal init(timetag: TimeTag) {
        self.timetag = timetag
    }

    public init(withDelay delay: TimeInterval) {
        self.timetag = TimeTag(time: Date(timeIntervalSinceNow: delay))
    }

    /// Equatable
    public static func == (lhs: OSCTimeTag, rhs: OSCTimeTag) -> Bool {
        return lhs.timetag == rhs.timetag
    }
}
