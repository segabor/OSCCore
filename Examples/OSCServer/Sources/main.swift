import UDP
import OSCCore

let clientPort    = 5050



func receiveOSCMessage(port : Int) -> OSCMessage? {

	// open socket and listen for incoming packet
	guard let udpSocket = try? UDPSocket(ip: IP(port: clientPort))
	else {
		return nil
	}

	/// fetch message over the UDP tunnel
	guard let (buf, _) = try? udpSocket.receive(1536)
	else {
		return nil
	}

	/// create OSC message
	return OSCMessage(data: buf.bytes)
}



if let msg = receiveOSCMessage(port: clientPort),
	let parsed_msg = msg.parse() {

	/// print out message content
	print("address: \(parsed_msg.address)")
	parsed_msg.args.forEach { arg in
		print("arg: \(arg)")
	}
}

