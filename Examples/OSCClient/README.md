Basic OSC client
================

# Usage

Install an OSC test package that captures your test messages. I use osc-tools for test purposes. Grab it from here: [osc-tools](https://github.com/bearstech/osc-tools)

Edit Sources/main.swift to configure server address and port and the message you want to send.

Start OSC server. If you use osc-tools, run this command within the project folder

    ./scripts/osc_server_dump -H localhost -p 5051 -t /hello

Build and run the client

    swift build
    ./.build/debug/OSCClient

Now you should see the following output

    /hello is [1234, 'test'] ('127.0.0.1', 5050)

