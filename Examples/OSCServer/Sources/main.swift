import C7 /// required for Data type
import Result
import UDP
import OSCCore


// the error part of Result
enum MyError : Error {
	case SocketError
	case ReceiveError
	case ParseError
}


// open port
func createSocket(port : Int) -> Result<UDPSocket, MyError> {
	if let udpSocket = try? UDPSocket(ip: IP(port: port)) {
		return .success(udpSocket)
	} else {
		return .failure(.SocketError)
	}
}

// receive message over UDP channel
func receivePacket(_ socket : UDPSocket) -> Result<Data, MyError> {
	if let (buf, _) = try? socket.receive(1536) {
		print("Received \(buf.count) bytes")
		return .success(buf)
	} else {
		return .failure(.ReceiveError)
	}
}

// parse OSC message
func parseMessage(_ buf : Data ) -> Result<ParsedMessage, MyError> {
	let msg = OSCMessage(data: buf.bytes )
	if let parsed = msg.parse()	{
		return .success(parsed)
	} else {
		return .failure(.ParseError)
	}
}

// register an observer
OSCMessageDispatcher.register("/hello") { (msg: OSCMessage)->Void in 
	print("Message arrived")	
}

// The main loop
let result : Result<UDPSocket, MyError> = createSoclet(port: 5050)
switch result {
case let .success(sock):
	while true {

	}
default:
}

// -- old -- //

// let it flow ...
let result =
	createSocket(port: 5050)
 	>>- receivePacket
	>>- parseMessage



// see the result!
switch result {
case let .success(msg):
	/// print out message content
	print("address: \(msg.address)")
	msg.args.forEach { arg in
		print("arg: \(arg)")
	}
case .failure(_):
	print("Failed to retrieve message")
}

