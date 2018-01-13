//
//  RGBA.swift
//  OSCCore
//
//  Created by Sebestyén Gábor on 2017. 12. 29..
//

public struct RGBA {
    public let red: UInt8
    public let green: UInt8
    public let blue: UInt8
    public let alpha: UInt8

    public init(red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }
}
