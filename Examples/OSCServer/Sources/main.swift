import UDP
import OSCCore
import C7

let clientPort    = 5050



func receiveOSCMessage(port : Int) -> OSCMessage? {

	// open socket and listen for incoming packet
	guard let udpSocket = try? UDPSocket(ip: IP(port: clientPort))
	else {
		return nil
	}


	func catchPackets(socket : UDPSocket) -> Data? {
		/// this buffer collects incoming packets
		var buf = Data()
		let maxBytes = 1024

		/// run until we have the entire stuff over the channel
		while true {
			guard let (pkt, _) = try? socket.receive(maxBytes)
			else {
				/// something went wrong ...
				return nil
			}

			/// append packet to buffer
			buf += pkt

			/// packet is less than the maximum size
			///   this was the last packet, bye
			if pkt.count < maxBytes {
				return buf
			}
		}
 	}

	/// fetch message over the UDP tunnel
	guard let buf = catchPackets(socket: udpSocket)
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

