import UDP



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
}


extension UDPClient : Sender {
  public func sendMessage(_ message: OSCConvertible) {
    try? socket.write(message.oscValue, deadline: 1.second.fromNow())
  }
}


public class UDPServer {

  let socket: UDPSocket
  
  public let dispatcher = MessageDispatcher()
  
  public init(socket: UDPSocket) {
    self.socket = socket
  }

  public convenience init(remotePort: Int) throws {
    let sock = try UDPSocket(ip: IP(port: remotePort))
    self.init( socket: sock)
  }
}


public extension UDPServer {
  
  // read packet and pass decoded message values to handler
  public func receiveMessages(decoder: MessageDecoder, _ handler: @escaping MessageEventHandler ) {
    do {
      let (buffer, _) = try socket.read(upTo: 1536, deadline: .never)

      decoder(buffer.bytes, handler)
    } catch {
      print("Failed to read message \(error)")
    }
  }
  
  public func listen() {
    
    let defaultDecoder = processRawData

    while true {
      receiveMessages(decoder: defaultDecoder) { (event: MessageEvent) in
        self.dispatcher.fire(event: event)
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

