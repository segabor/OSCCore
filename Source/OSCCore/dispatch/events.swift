//
//  events.swift
//  OSCCore
//
//  Created by Sebestyén Gábor on 2017. 11. 19..
//

import Foundation

// MARK: Message Events

public typealias MessageEvent = (when: Date, message: OSCMessage)

public typealias MessageEventHandler = (MessageEvent) -> Void

public typealias MessageHandler = (OSCMessage) -> Void
