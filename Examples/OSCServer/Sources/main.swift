import OSCCore


if let srv = try? OSCServer(port: 5050) {
  srv.register(pattern: "/hello") { msg in
    
    if let parsed = msg.parse() {
      
      print("Address: \(parsed.address)")
      parsed.args.forEach { arg in
        print("arg: \(arg)")
      }
    }
  }

  srv.listen()
}
