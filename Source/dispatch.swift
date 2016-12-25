//
//  dispatch.swift
//  OSCCore
//
//  Created by Gábor Sebestyén on 11/08/16.
//
//

import Foundation

public typealias MessageEvent = (when: Date, message: OSCMessage)

public typealias MessageEventHandler = (MessageEvent) -> ()

public typealias MessageHandler = (OSCMessage) -> ()

public final class MessageDispatcher {

  /// list of pattern -> handler pairs
  private var listeners = [String: MessageHandler]()

  /// register a message listener
  public func register(pattern: String, _ listener: @escaping MessageHandler) {
      listeners[pattern] = listener
  }

  /// remove listener
  public func unregister(pattern: String) {
    listeners.removeValue(forKey: pattern)
  }

  /// fire event
  public func fire(event: MessageEvent) {
    listeners.forEach { ptn, handler in
      if match(address: event.message.address, pattern: ptn) {
        handler(event.message)
      }
    }
  }
}
