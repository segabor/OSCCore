import UDP


public class OSCServer: MessageDispatcher {
  public typealias Message = OSCMessage

  let socket: UDPSocket
  let dispatcher = OSCMessageDispatcher

  init(port: Int) throws {
    socket = try UDPSocket(ip: IP(port: port))
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
    let deadline = 5.seconds.fromNow()

    while true {
      do {
        let (buffer, _) = try socket.read(upTo: 4096, deadline: deadline)

        let msg = OSCMessage(data: buffer )
      } catch {
        // DISPLAY SOME ERROR
        break
      }
    }
  }
}