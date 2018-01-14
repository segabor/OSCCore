#if os(Linux)
    import Glibc
#else
    import Darwin
#endif
    
import OSCCore

// create UDP socket
let myPort: Int = 57150
let scPort: Int32 = 57110

let channel = UDPClient(host: "127.0.0.1", port: scPort)

// ---- //


/// simple function that dumps contents of OSCMessage / OSCBundle
func debugOSCPacket(_ packet: OSCConvertible) {
    switch packet {
    case let msg as OSCMessage:
        let argsString: String = msg.args.map{
            if let arg = $0 {
                return String(describing: arg)
            } else {
                return "nil"
            }
        }.joined(separator: ", ")
        print("[message] Address: \(msg.address); Arguments: [\(argsString)]")
    case let bundle as OSCBundle:
        print("[bundle] Timestamp: \(bundle.timetag); elements:")
        bundle.content.forEach {
            debugOSCPacket($0)
        }
    default:
        ()
    }
}

// ---- //

/// assemble a synth

let synthID = Int32(4)

let bndl = OSCBundle(timetag: OSCTimeTag.immediate, content: [
    // "/s_new", name, node ID, pos, group ID
    OSCMessage(address: "/s_new", args: ["sine", synthID, Int32(1), Int32(1)]),
    // "/n_set", "amp", sine amplitude
    OSCMessage(address: "/n_set", args: [synthID, "amp", Float32(0.5)]),
    // "/n_set", "freq", sine frequency
    OSCMessage(address: "/n_set", args: [synthID, "freq", Float32(440.0)])
])

bndl.send(over: channel)
sleep(1)

// get and print out frequency number from SuperCollider
OSCMessage(address: "/s_get", args: [synthID, "freq"])
    .send(over: channel)

if let pkt = channel.receive() {
    debugOSCPacket(pkt)
} else {
    print("FATAL! Received no response!")
}

// let synth beeping for two secs
sleep(2)

// free synth node
OSCMessage(address: "/n_free", args: [synthID])
    .send(over: channel)

exit(0)
