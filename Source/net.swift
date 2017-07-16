import Foundation

import Socket


// MARK: OSC packet I/O

public protocol PacketSender {

  func send(packet: OSCConvertible)
}

public protocol PacketReceiver {

  func receivePacket() throws -> OSCConvertible?
}



public extension OSCMessage {

  public func send(over channel: PacketSender) {
    channel.send(packet: self)
  }

}

public extension OSCBundle {

  public func send(over channel: PacketSender) {
    channel.send(packet: self)
  }

}


// MARK: UDP packet sender (aka client)

public class UDPClient {

  public let socket: Socket
  public let address : Socket.Address

  public init(withSocket socket: Socket, address: Socket.Address) {
    self.socket = socket
    self.address = address
  }

  public convenience init?(host: String, port: Int32) {
    
    guard
      let address : Socket.Address = Socket.createAddress(for: host, on: port),
      let socket = try? Socket.create(family: .inet, type: .datagram, proto: .udp)
    else {
      return nil
    }
    
    self.init(withSocket: socket, address: address)
  }

  deinit {
    socket.close()
  }
}



extension UDPClient : PacketSender {
  
  public func send(packet: OSCConvertible) {
    let _ = packet.oscValue.withUnsafeBufferPointer {
      try! socket.write(from: $0.baseAddress!, bufSize: $0.count, to: address)
    }
  }
}



// MARK: UDP packet receiver

public class UDPReceiver : PacketReceiver {
  
  let socket: Socket
  let listenerPort: Int
  
  let messageDecoder : MessageDecoder = decodeBytes

  public init?(listenerPort: Int) {
    guard let sock = try? Socket.create(family: .inet, type: .datagram, proto: .udp) else {
      return nil
    }

    try! sock.setReadTimeout(value: 100)
    
    self.socket = sock
    self.listenerPort = listenerPort
  }

  
  // returns OSC packet received over UDP socket
  public func receivePacket() throws -> OSCConvertible? {
    var receiveBuffer = UnsafeMutablePointer<CChar>.allocate(capacity: 1024)
    defer {
      receiveBuffer.deallocate(capacity: 1024)
    }

    guard let listenResult = try?  socket.readDatagram(into: receiveBuffer, bufSize: 1024) else {
      return nil
    }

    let rawBytes = receiveBuffer.withMemoryRebound(to: Byte.self, capacity: listenResult.bytesRead) { (bytesPointer : UnsafeMutablePointer<Byte>) -> [Byte] in
      return [Byte](UnsafeBufferPointer<Byte>.init(start: bytesPointer, count: listenResult.bytesRead))
    }
    
    return messageDecoder(rawBytes)
  }
  
  deinit {
    socket.close()
  }
}

// MARK: OSC message reader

public final class OSCReader {
  
  let channel: PacketReceiver

  public init(receiver: PacketReceiver) {
    self.channel = receiver
  }
  
  public func read() -> OSCConvertible? {
    guard let oscPacket = try? channel.receivePacket() else {
      return nil
    }
    
    return oscPacket
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

// Export observer interface
extension OSCListener : MessageEventSource {

  public func register(pattern: String, _ listener: @escaping MessageHandler) {
    dispatcher.register(pattern: pattern, listener)
  }
  
  public func unregister(pattern: String) {
    dispatcher.unregister(pattern: pattern)
  }
}

