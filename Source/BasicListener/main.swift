import OSCCore

let listener = UDPListener(listenerPort: Int(57110))

listener.listen { receivedMessage in
    if let msg = receivedMessage as? OSCMessage {
        print("Received \(msg)")
    }
    return nil
}
