//
//  BasicMessageDispatcher.swift
//  OSCCore
//
//  Created by Sebestyén Gábor on 2017. 11. 19..
//

public final class BasicMessageDispatcher {

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
        // dispatchMessageEvent(event: event, listeners: listeners)
        listeners.forEach { ptn, handler in
            if match(address: event.message.address, pattern: ptn) {
                handler(event.message)
            }
        }
    }
}
