import UDP

// The IN part of OSC message channel
public protocol OSCSource {

  // is channel available for read
  func available() -> Bool
  
  func release()
  
  func read() throws -> (packet: OSCConvertible, timetag: OSCTimeTag)
  
  // read out a packet and pass it to a handler function
  func read(_ handler: (OSCMessage, OSCTimeTag) -> ())
  
}

// The OUT part of OSC message channel
public protocol OSCSink {
  
  func send(packet: OSCConvertible)
}


public class UDPClient {

  public let socket: UDPSendingSocket

  public init(socket: UDPSendingSocket) {
    self.socket = socket
  }

  public convenience init?(localPort: Int, remotePort: Int) {
    guard
      let clientIP = try? IP(port: localPort),
      let serverIP = try? IP(port: remotePort),
      let sock = try? UDPSocket(ip: clientIP).sending(to: serverIP)
    else {
      return nil
    }

    self.init(socket: sock)
  }

  public func send(message: OSCConvertible) throws {
    try socket.write(message.oscValue, deadline: 1.second.fromNow())
  }
}


public class UDPServer: MessageDispatcher {
  public typealias Message = OSCMessage

  let socket: UDPSocket
  let dispatcher = OSCMessageDispatcher

  public init(socket: UDPSocket) {
     self.socket = socket
  }

  public convenience init(remotePort: Int) throws {
    let sock = try UDPSocket(ip: IP(port: remotePort))
    self.init( socket: sock )
  }

  // override
  public func register(pattern: String, _ listener: @escaping (OSCMessage) -> Void) {
    dispatcher.register(pattern: pattern, listener)
  }

  // override
  public func unregister(pattern: String) {
    dispatcher.unregister(pattern: pattern)
  }

  // override
  public func dispatch(message: OSCMessage) {
    dispatcher.dispatch(message: message)
  }

  public func listen() {
    while true {
      do {
        let (buffer, _) = try socket.read(upTo: 1536, deadline: .never)

        processRawData(data: buffer.bytes) { msg, timetag in
          self.dispatcher.dispatch(message: msg)
        }
      } catch {
        print("Failed to read message \(error)")
        break
      }
    }
  }
}



public extension UDPServer {
  public func readMessages(_ fun: @escaping (OSCMessage, OSCTimeTag)->() ) {
    while true {
      do {
        let (buffer, _) = try socket.read(upTo: 1536, deadline: .never)

        // pass raw data to message consumer
        processRawData(data: buffer.bytes, fun)
      } catch {
        print("Failed to read message \(error)")
        break
      }
    }
  }
}



/// create a server and client sharing the same UDP ports
public func createUDPBridge(localPort: Int, remotePort: Int) -> (client: UDPClient, server: UDPServer)? {
    
  do {
    let clientIP    = try IP(port: localPort)
    let serverIP    = try IP(port: remotePort)

    let sock        = try UDPSocket(ip: clientIP)
        
    let sendingSocket = sock.sending(to: serverIP)

    return (client: UDPClient(socket: sendingSocket ),
                         server: UDPServer(socket: sock))
  } catch {}
    
  return nil
}

