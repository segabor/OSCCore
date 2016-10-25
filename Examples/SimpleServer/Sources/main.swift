import OSCCore


if let srv = try? UDPServer(port: 5050) {
  srv.register(pattern: "/hello") { (msg: OSCMessage) in
    
    print("Address: \(msg.address)")
    msg.args.forEach { arg in
      print("arg: \(arg)")
    }
  }

  srv.listen()
}
