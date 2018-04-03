import Foundation
#if os(Linux)
import Glibc
#else
import Darwin
#endif

import OSCCore

var port: Int = 57110

if CommandLine.arguments.count > 1 {
    if let parsedPort = Int(CommandLine.arguments[CommandLine.arguments.endIndex-1]) {
        port = parsedPort
    } else {
        print("Usage: \(CommandLine.arguments[0]) <port number>")
        exit(0)
    }
}

print("Start listening on port \(port)")

let receiver = UDPListener(listenerPort: port)

receiver.listen { receivedMessage in
    if let msg = receivedMessage as? OSCMessage {
        print("   \(msg.address): \(msg.args)")
    } else if let bndl = receivedMessage as? OSCBundle {
        print("\(bndl.timetag.toDate())")
        for oscItem in bndl.content {
            if let msg = oscItem as? OSCMessage {
                print("    \(msg.address): \(msg.args)")
            }
        }
    }
    return nil
}
