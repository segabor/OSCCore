//
//  OSCBundle+MessageEventHandler.swift
//  OSCCore
//
//  Created by Sebestyén Gábor on 2017. 11. 19..
//

    /// Decompose OSC Bundle content and pass each item to handler function
extension OSCBundle {
    func unwrap(_ handler: @escaping MessageEventHandler) {
        recursive { visit, parentBundle in
            parentBundle.content.forEach { (item: OSCConvertible) in
                switch item {
                case let msg as OSCMessage:
                    handler(MessageEvent(when: parentBundle.timetag.toDate(), message: msg))
                case let childBundle as OSCBundle:
                    visit(childBundle)
                default:
                    ()
                }
            }
            }(self)
    }
}

// MARK: recursive call support

///
/// Workaround for lambda recursion
/// See: http://stackoverflow.com/questions/30523285/how-do-i-create-a-recursive-closure-in-swift
///

private func unimplemented<T>() -> T {
    fatalError()
}

private func recursive<T, U>(f: (@escaping (((T) -> U), T) -> U)) -> ((T) -> U) { //swiftlint:disable:this identifier_name
    var g: ((T) -> U) = { _ in unimplemented() }

    g = { f(g, $0) }

    return g
}
