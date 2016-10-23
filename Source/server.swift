import UDP


public class OSCServer: MessageDispatcher {
  public typealias Message = OSCMessage

  let socket: UDPSocket
  let dispatcher = OSCMessageDispatcher

  public init(port: Int) throws {
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
    while true {
      do {
        let (buffer, _) = try socket.read(upTo: 1536, deadline: .never)

        if let msg = OSCMessage(data: buffer.bytes ) {
          dispatcher.dispatch(message: msg)
        } else if let bndl = OSCBundle(data: buffer.bytes) {

          // Temporary solution that collects messages and
          // dispatches them at once, disregarding
          // bundle timestamps
          var msgs = [OSCMessage]()

          // collect messages
          recursive{ f, bundle in
            bundle.content.forEach{ item in
              switch item {
              case let m as OSCMessage:
                msgs.append(m)
              case let b as OSCBundle:
                f(b)
              default:
                ()
              }
            }
          }(bndl)

          // dispatc'em!!
          msgs.forEach { dispatcher.dispatch(message: $0) }
        }
      } catch {
        print("Failed to read message \(error)")
        break
      }
    }
  }
}
