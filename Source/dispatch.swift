//
//  dispatch.swift
//  OSCCore
//
//  Created by Gábor Sebestyén on 11/08/16.
//
//

import Foundation


// MARK: Message Events

public typealias MessageEvent = (when: Date, message: OSCMessage)

public typealias MessageEventHandler = (MessageEvent) -> Void

public typealias MessageHandler = (OSCMessage) -> Void



// MARK: Transform bare OSC data to message events

public typealias MessageEventMaker = (OSCConvertible?, @escaping MessageEventHandler) -> Void

extension OSCBundle {
  /// Decompose OSC Bundle content and pass each item to handler function
  func unwrap(_ handler: @escaping MessageEventHandler) {
    recursive { visit, parentBundle in
      parentBundle.content.forEach { (item: OSCConvertible) in
        switch item {
        case let msg as OSCMessage:
          // FIXME: this is ugly!
          handler(MessageEvent(when: parentBundle.timetag.timetag.time, message: msg))
        case let childBundle as OSCBundle:
          visit(childBundle)
        default:
          ()
        }
      }
    }(self)
  }
}



/// Pass transformed OSC messages as events to event handler function
/// FIXME: better naming
public func makeEvents(_ packet: OSCConvertible?, _ handler: @escaping MessageEventHandler) {
  if let message = packet as? OSCMessage {
    handler(MessageEvent(when: Date(), message: message))
  } else if let bundle = packet as? OSCBundle {
    bundle.unwrap(handler)
  }
}



/// basic message event dispatcher implementation
public func dispatchMessageEvent(event: MessageEvent, listeners: [String: MessageHandler] ) {
  listeners.forEach { ptn, handler in
    if match(address: event.message.address, pattern: ptn) {
      handler(event.message)
    }
  }
}



// MARK: Dispatching

// 'Observable' interface
public protocol MessageEventSource {

  /// register a message listener
  func register(pattern: String, _ listener: @escaping MessageHandler)
  
  /// remove listener
  func unregister(pattern: String)
  
}

public protocol MessageEventDispatcher {
  func fire(event: MessageEvent)
}

public protocol MessageDispatcher: MessageEventSource, MessageEventDispatcher {}

public final class BasicMessageDispatcher: MessageDispatcher {

  /// map of observers
  private var listeners = [String: MessageHandler]()

  /// register a message listener
  public func register(pattern: String, _ listener: @escaping MessageHandler) {
      listeners[pattern] = listener
  }

  /// remove listener
  public func unregister(pattern: String) {
    listeners.removeValue(forKey: pattern)
  }

  /// notify observes about the event
  public func fire(event: MessageEvent) {
    dispatchMessageEvent(event: event, listeners: listeners)
  }
}
