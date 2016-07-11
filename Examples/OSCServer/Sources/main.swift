import UDP
import OSCCore
import C7

let clientPort    = 5050
let pktSize       = 1024

if let udpSocket = try? UDPSocket(ip: IP(port: clientPort)) {

  var msg = Data() 
  while true {
    if let (pkt, ip) = try? udpSocket.receive(pktSize) {
      msg += pkt
      print("Received \(pkt.count) bytes")

      if pkt.count < pktSize {
        break
      }
    } else {
      print("EOL")
      break
    }
  }
  print("Message arrived")

  let osc_msg = OSCMessage(data: msg.bytes)
  if let x = osc_msg.parse() {
    print("address: \(x.address)")
    x.args.forEach{ arg in print("arg: \(arg)") }
  } else {
    print("Failed to parse message")
  }
}
