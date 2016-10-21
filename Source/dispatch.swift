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
    
    func dispatch(message : Message)
}



/**
 
 # Basic implementation
 
 **/
public final class SimpleMessageDispatcher : MessageDispatcher {
    public typealias Message = OSCMessage

    private var listeners = [String : [(OSCMessage) -> Void]]()

    
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


    public func dispatch(message: OSCMessage) {
        
        listeners.forEach {
            let ptn = $0.key
            if match(address: message.address, pattern: ptn) {
                // dispatch message
                print("Address matched with pattern \(ptn), delivering message ...")
                $0.value.forEach { $0(message) }
            }
        }
    }
}



/**
 
 # Default Message Dispatcher
 
 **/
let OSCMessageDispatcher = SimpleMessageDispatcher()
