import OSCCore

let clientPort    = 5050
let remotePort    = 5051

let msg = OSCMessage(address: "/hello", args: 1234, "test")

if let client = UDPClient(port: clientPort, remotePort: remotePort) {
  try client.send(message: msg)
}
