import UDP
import OSCCore

let clientPort    = 5050
let remoteAddress = "localhost"
let remotePort    = 5051

let msg = OSCMessage(address: "/hello", args: 1234, "test")
let udpSocket = try? UDPSocket(ip: IP(port: clientPort))
try udpSocket?.send(Data(msg.data), ip: IP(remoteAddress: remoteAddress, port: remotePort))

