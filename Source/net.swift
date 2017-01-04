import UDP


// MARK: OSC packet I/O

public protocol PacketSender {

  var available: Bool { get }

  func send(packet: OSCConvertible)
}

public protocol PacketReceiver {

  var available: Bool { get }
  
  func receivePacket() throws -> OSCConvertible?
}



public extension OSCMessage {

  public func send(over channel: PacketSender) {
    if channel.available {
      channel.send(packet: self)
    }
  }

}

public extension OSCBundle {

  public func send(over channel: PacketSender) {
    if channel.available {
      channel.send(packet: self)
    }
  }

}


// MARK: UDP packet sender (aka client)

public class UDPClient {

  public let socket: UDPSendingSocket

  public init(withSocket socket: UDPSendingSocket) {
    self.socket = socket
  }

  public convenience init?(localPort: Int, remotePort: Int) {
    guard
      let localIP = try? IP(port: localPort),
      let remoteIP = try? IP(port: remotePort),
      let socket = try? UDPSocket(ip: localIP).sending(to: remoteIP)
    else {
      return nil
    }

    self.init(withSocket: socket)
  }
}



extension UDPClient : PacketSender {
  
  public var available : Bool {
    return !socket.closed
  }
  
  public func send(packet: OSCConvertible) {
    try? socket.write(packet.oscValue, deadline: 1.second.fromNow())
  }
}



// MARK: UDP packet receiver

public class UDPReceiver : PacketReceiver {
  
  let socket: UDPSocket

  let messageDecoder : MessageDecoder = decodeBytes

  public var available: Bool {
    return !socket.closed
  }
  
  public init(withSocket socket: UDPSocket) {
    self.socket = socket
  }

  
  // returns OSC packet received over UDP socket
  public func receivePacket() throws -> OSCConvertible? {
    guard !socket.closed else {
        return nil
    }
    
    let (buffer, _) = try socket.read(upTo: 1536, deadline: .never)
    
    return messageDecoder(buffer.bytes)
  }
}



// MARK: OSC message listener

public class OSCListener {

  let channel: PacketReceiver
  
  public let dispatcher = BasicMessageDispatcher()
  
  
  public init(receiver: PacketReceiver) {
    self.channel = receiver
  }
  
  public func start() {

    while true {
      
      do {
      
        // read an OSC packet
        if let pkt = try channel.receivePacket() {
          makeEvents(pkt) { event in
            self.dispatcher.fire(event: event )
          }
        } else {
          break
        }
        
      } catch {
        print("Listening aborted due to error \(error)")
        
        break
      }
    
    }
  }
}

// MARK: UDP extension

public extension OSCListener {
  
  public convenience init(withSocket socket: UDPSocket) {
    self.init(receiver: UDPReceiver(withSocket: socket))
  }
  
  public convenience init(remotePort: Int) throws {
    let sock = try UDPSocket(ip: IP(port: remotePort))
    self.init(withSocket: sock)
  }
  
}


// Export observer interface
extension OSCListener : MessageEventSource {

  public func register(pattern: String, _ listener: @escaping MessageHandler) {
    dispatcher.register(pattern: pattern, listener)
  }
  
  public func unregister(pattern: String) {
    dispatcher.unregister(pattern: pattern)
  }
}



// MARK: Two-way communication

public struct UDPBridge {
  let outSocket: UDPSendingSocket
  let inSocket: UDPSocket
}


/// create a pair of UDP sockets for two-way communication
public func createUDPChannel(localPort: Int, remotePort: Int) -> UDPBridge? {
    
  guard
    let localIP    = try? IP(port: localPort),
    let remoteIP   = try? IP(port: remotePort),

    let socket     = try? UDPSocket(ip: localIP)
  else {
    return nil
  }
    
  let sendingSocket = socket.sending(to: remoteIP)

  return UDPBridge(outSocket: sendingSocket, inSocket: socket)
}

public extension UDPClient {
  public convenience init(withBridge bridge: UDPBridge) {
    self.init(withSocket: bridge.outSocket)
  }
}

public extension OSCListener {
  public convenience init(withBridge bridge: UDPBridge) {
    self.init(withSocket: bridge.inSocket)
  }
}

