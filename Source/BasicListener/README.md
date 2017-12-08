# What is this?

A basic example that dumps out OSC packets captured on port 51770.

## Compile Example

Just execute `swift build` command.

## Run Example

Run `./.build/debug/BasicListener`. It will start listening on port 51770.

But you can specify custom port number by setting it as an argument. `./.build/debug/BasicListener 3330`. Now listener will capture events coming from [TUIO Simulator](https://github.com/mkalten/TUIO11_Simulator).
