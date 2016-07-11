Basic OSC server
================

This example captures and prints out OSC messages

# Usage

Install an OSC test package that captures your test messages. I use osc-tools for test purposes. Grab it from here: [osc-tools](https://github.com/bearstech/osc-tools)

Build and run the test server

    swift build
    ./.build/debug/OSCServer

It listens on port 5050 waiting for messages.

Send an OSC message. If you use osc-tools, run this command within the tools project folder

    ./scripts/osc_client -p 5050 -t /hello -m 1234

Now you should see the following output

    Received 16 bytes
    Message arrived
    address: /hello
    arg: 123

