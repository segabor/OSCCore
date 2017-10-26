//
//  CommunicationTests.swift
//  OSCCoreTests
//
//  Created by Sebestyén Gábor on 2017. 09. 02..
//

@testable import OSCCore
import XCTest
import Foundation
import Dispatch

import Socket

#if os(Linux)
  import Glibc
#endif

class CommunicationTests: XCTestCase {

    let port: Int32 = 1337
    let host: String = "127.0.0.1"
    let path: String = "/tmp/server.test.socket"

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    // NOTE: copied from https://github.com/IBM-Swift/BlueSocket/blob/master/Tests/SocketTests/SocketTests.swift
    func createUDPHelper(family: Socket.ProtocolFamily = .inet) throws -> Socket {
      
        let socket = try Socket.create(family: family, type: .datagram, proto: .udp)
        XCTAssertNotNil(socket)
        XCTAssertFalse(socket.isConnected)
        XCTAssertTrue(socket.isBlocking)
      
        return socket
    }


    func testSendOverUDP() {
        let hostname = "127.0.0.1"
        let port: Int32 = 1337
      
        do {
          
            let socket = try self.createUDPHelper()
          
            // Defer cleanup...
            defer {
                // Close the socket...
                socket.close()
                XCTAssertFalse(socket.isActive)
            }
          
            // test me here
            let testMessage : OSCMessage = OSCMessage(address: "/s_new", args: "sine", Int32(100), Int32(1), Int32(1) )
          
            let channel = UDPClient(host: hostname, port: port)
          
            let queue: DispatchQueue? = DispatchQueue.global(qos: .userInteractive)
            guard let pQueue = queue else {
              
                print("Unable to access global interactive QOS queue")
                XCTFail()
                return
            }
            
            pQueue.async { [unowned self] in
              
                let listener = UDPListener(listenerPort: Int(port))
                var capturedMessage : OSCMessage?
                listener.listen() { receivedMessage in
                    if let msg = receivedMessage as? OSCMessage {
                        capturedMessage = msg
                    }
                    return nil
                }

                if let value = capturedMessage {
                    XCTAssertTrue(testMessage.address == value.address)
                    XCTAssertTrue(testMessage.args == value.args)
                } else {
                    XCTFail("No message received")
                }
            }

            // Send test message, result will be checked in the listener thread
            testMessage.send(over: channel)

            // Need to wait for the server to go down before continuing...
            #if os(Linux)
                _ = Glibc.sleep(1)
            #else
                _ = Darwin.sleep(1)
            #endif

        } catch let error {
            // See if it's a socket error or something else...
            guard let socketError = error as? Socket.Error else {
              
                print("Unexpected error...")
                XCTFail()
                return
            }
          
            print("testReadWriteUDP Error reported: \(socketError.description)")
            XCTFail()
        }
    }

    func testReadWriteOverUDP() {
        let hostname = "127.0.0.1"
        let port: Int32 = 1338
        
        do {
            
            let socket = try self.createUDPHelper()
            
            // Defer cleanup...
            defer {
                // Close the socket...
                socket.close()
                XCTAssertFalse(socket.isActive)
            }
            
            // test message to send
            let testMessage : OSCMessage = OSCMessage(address: "/s_get", args: Int32(4), "freq")
            // and the correct response
            let testResponse : OSCMessage = OSCMessage(address: "/n_set", args: Int32(4), "freq", Int32(440))
            
            let channel = UDPClient(host: hostname, port: port)
            
            let queue: DispatchQueue? = DispatchQueue.global(qos: .userInteractive)
            guard let pQueue = queue else {
                
                print("Unable to access global interactive QOS queue")
                XCTFail()
                return
            }
            
            pQueue.async { [unowned self] in
                
                let listener = UDPListener(listenerPort: Int(port))
                listener.listen() { receivedMessage in
                    guard
                        let msg = receivedMessage as? OSCMessage,
                        msg.address == "/s_get"
                    else {
                        return nil
                    }

                    return testResponse
                }
            }

            // Wait a bit before sending anything to the server 
            #if os(Linux)
                _ = Glibc.sleep(1)
            #else
                _ = Darwin.sleep(1)
            #endif

            // Send test message, result will be checked in the listener thread
            testMessage.send(over: channel)
            
            if let receivedPacket = channel.receive(),
                let response = receivedPacket as? OSCMessage {
                XCTAssertTrue(testResponse.address == response.address)
                XCTAssertTrue(testResponse.args == response.args)

            } else {
                XCTFail("Received no response")
            }

            // Need to wait for the server to go down before continuing...
            #if os(Linux)
                _ = Glibc.sleep(1)
            #else
                _ = Darwin.sleep(1)
            #endif
            
        } catch let error {
            // See if it's a socket error or something else...
            guard let socketError = error as? Socket.Error else {
                
                print("Unexpected error...")
                XCTFail()
                return
            }
            
            print("testReadWriteUDP Error reported: \(socketError.description)")
            XCTFail()
        }
    }
}

#if os(Linux)
extension CommunicationTests {
    static var allTests: [(String, (CommunicationTests) -> () throws -> Void)] {
        return [
            ("testSendOverUDP", testSendOverUDP),
            ("testReadWriteOverUDP", testReadWriteOverUDP)
        ]
    }
}
#endif
