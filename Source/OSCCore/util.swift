//
//  util.swift
//  OSCCore
//
//  Created by Gábor Sebestyén on 22/04/16.
//  Copyright © 2016 Gábor Sebestyén. All rights reserved.
//




///
/// Workaround for lambda recursion
/// See: http://stackoverflow.com/questions/30523285/how-do-i-create-a-recursive-closure-in-swift 
///



func unimplemented<T>() -> T
{
      fatalError()
}



func recursive<T, U>(f: (@escaping (((T) -> U), T) -> U)) -> ((T) -> U)
{
    var g: ((T) -> U) = { _ in unimplemented() }

    g = { f(g, $0) }
              
    return g
}

