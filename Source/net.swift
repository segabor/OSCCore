import Foundation

import Socket


// MARK: OSC packet I/O

public protocol OSCChannel {

  func send(packet: OSCConvertible)
  func receive() -> OSCConvertible?

}

public extension OSCMessage {

  public func send(over channel: OSCChannel) {
    channel.send(packet: self)
  }

}

public extension OSCBundle {

  public func send(over channel: OSCChannel) {
    channel.send(packet: self)
  }

}

// MARK : base class for two-way UDP communication

public class UDPChannel : OSCChannel {
  
  let socket : Socket
  
  public init(socket: Socket) {
    self.socket = socket
    
    try! socket.setReadTimeout(value: 100)
  }

  // returns OSC packet received over UDP socket
  public func receive() -> OSCConvertible? {
    var receiveBuffer = UnsafeMutablePointer<CChar>.allocate(capacity: 1024)
    defer {
      receiveBuffer.deallocate(capacity: 1024)
    }
    
    guard let readResult = try? socket.readDatagram(into: receiveBuffer, bufSize: 1024) else { return nil }
    
    return extract(contentOf: receiveBuffer, length: readResult.bytesRead)
  }

  public func send(packet: OSCConvertible) {
    // ABSTRACT FUNCTION - IMPLEMENT IN SUBCLASSES
  }

  deinit {
    socket.close()
  }
}



// MARK: UDP client

public class UDPClient : UDPChannel {

  let address : Socket.Address

  public init(host: String, port: Int32) {
    
    guard
      let socket = try? Socket.create(family: .inet, type: .datagram, proto: .udp),
      let address = Socket.createAddress(for: host, on: port)
    else {
      fatalError("Failed to establish UDP connection to host \(host):\(port)")
    }
    
    self.address = address

    super.init(socket: socket)
  }

  public override func send(packet: OSCConvertible) {
    let _ = packet.oscValue.withUnsafeBufferPointer {
      try! socket.write(from: $0.baseAddress!, bufSize: $0.count, to: address)
    }
  }
}



// MARK: OSC message listener
// TBD
