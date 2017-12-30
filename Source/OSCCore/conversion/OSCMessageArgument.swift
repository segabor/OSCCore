//
//  OSCType.swift
//  OSCCore
//
//  Created by Sebestyén Gábor on 2017. 11. 18..
//

import Foundation

///
/// Types adopting this protocol
/// can be part of OSC message arguments
/// All arguments are denoted with a distinct type tag
/// defined in TypeTagValues enum
///
public protocol OSCMessageArgument: OSCConvertible {
    var oscType: TypeTagValues { get }
}
