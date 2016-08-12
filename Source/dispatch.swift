//
//  dispatch.swift
//  OSCCore
//
//  Created by Gábor Sebestyén on 11/08/16.
//
//

import Foundation


public protocol MessageDispatcher {

    associatedtype Message
    
    /**
     
     # Register for OSC events

     - Parameter pattern: OSC address pattern to observe
     - Parameter body: closure that will be executed upon

     **/
    func register(pattern : String, _ listener : @escaping (Message)->Void )
    
    func unregister(pattern: String)
    
    func dispatch(address : String, message : Message)
}



/**
 
 # Basic implementation
 
 **/
public final class SimpleMessageDispatcher : MessageDispatcher {
    public typealias Message = OSCMessage

    private let queue : DispatchQueue

    private var listeners = [String : [(OSCMessage) -> Void]]()

    
    public init(queue : DispatchQueue) {
        self.queue = queue
    }
    
    public func register(pattern: String, _ listener: @escaping (OSCMessage) -> Void) {
        
        if var list = listeners[pattern] {
            list.append(listener)
        } else {
            listeners[pattern] = [listener]
        }
    }

    
    
    public func unregister(pattern: String) {
        if listeners[pattern] != nil {
            listeners.removeValue(forKey: pattern)
        }
    }

    
    
    public func dispatch(address : String, message: OSCMessage) {
        queue.sync {
            listeners.forEach {
                if address == $0.key {
                    // dispatch message
                    $0.value.forEach { $0(message) }
                }
                
            }
        }
    }
}



/**
 
 # Default Message Dispatcher
 
 **/
let OSCMessageDispatcher = SimpleMessageDispatcher(queue: DispatchQueue(label:"OSC"))
