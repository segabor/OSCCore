//
//  OSCType.swift
//  OSCCore
//
//  Created by Sebestyén Gábor on 2017. 11. 18..
//

import Foundation

///
/// Types adopting this protocol
/// can be converted to OSC value
///
public protocol OSCType: OSCConvertible {
    var oscType: TypeTagValues { get }
}
