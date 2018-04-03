//
//  matcher.swift
//  OSCCore
//
//  Created by Gábor Sebestyén on 13/08/16.
//
//

import Foundation

///
/// Function that matches address to a GLOB like pattern
///
func matchComponents(address: String, pattern: String) -> Bool { //swiftlint:disable:this swiftlint:disable:this
    let fullAddressRange = address.startIndex..<address.endIndex
    let fullPatternRange = pattern.startIndex..<pattern.endIndex
    return matchComponent(address: address[fullAddressRange], pattern: pattern[fullPatternRange])
}

func matchComponent(address: Substring, pattern: Substring) -> Bool { //swiftlint:disable:this function_body_length swiftlint:disable:this cyclomatic_complexity swiftlint:disable:this line_length
    var si = address.startIndex
    var pi = pattern.startIndex

    while pi < pattern.endIndex {
        guard si < address.endIndex || pattern[pi] == "*" else {
            return false
        }

        let char = pattern[pi]
        pi = pattern.index(after: pi)

        switch char {
        case "*":

            // consume star wild cards
            while pi < pattern.endIndex && pattern[pi] == "*" && pattern[pi] != "/" {
                pi = pattern.index(after: pi)
            }

            // pattern ending with stars matches address part
            if pi == pattern.endIndex {
                return true
            }

            // in case no other wild cards are found ...
            if pattern[pi] != "?" || pattern[pi] != "[" || pattern[pi] != "{" {
                // loop while
                while si < address.endIndex && pattern[pi] != address[si] {
                    si = address.index(after: si)
                }
            }

            while si < address.endIndex {
                if matchComponent(address: address[si...], pattern: pattern[pi...]) {
                    return true
                }
            }

            return false
        case "?":
            if si < address.endIndex {
                break
            }

            return false
            /*
             * set specification is inclusive, that is [a-z] is a, z and
             * everything in between. this means [z-a] may be interpreted
             * as a set that contains z, a and nothing in between.
             */
        case "[":

            let negate = (pattern[pi] == "!")
            if negate {
                pi = pattern.index(after: pi)
            }

            var match = false

            while !match && pi < pattern.endIndex {

                if pi == pattern.endIndex {
                    return false
                }

                // pop next pattern character
                let patternChar = pattern[pi]
                pi = pattern.index(after: pi)

                // detect range
                // case c-c
                if patternChar == "-" {
                    // skip char
                    pi = pattern.index(after: pi)
                    if pi == pattern.endIndex {
                        return false
                    }

                    if pattern[pi] != "]" {
                        if address[si] == patternChar || address[si] == pattern[pi]
                            || (address[si] > patternChar && address[si] < pattern[pi]) {
                            match = true
                        }
                    } else { // c-]
                        if address[si] >= patternChar {
                            match = true
                        }
                        break
                    }
                } else {
                    // cc or c]
                    if patternChar == address[si] {
                        match = true
                    }
                    if pattern[pi] != "]" {
                        if pattern[pi] == address[si] {
                            match = true
                        }
                    } else {
                        break
                    }
                }
            }

            // FIXME: negate result
            if negate == match {
                match = false
            }

            // if there is a match, skip past the cset and continue on
            while pi < pattern.endIndex && pattern[pi] != "]" {
                pi = pattern.index(after: pi)
            }

            if pi == pattern.endIndex {
                return false
            } else {
                // consume closing character
                pi = pattern.index(after: pi)
            }
        case "{":

            let place = si // to backtrack
            var remainder = pi // to forward-track

            // iterate to the end of the choice list
            while remainder < pattern.endIndex && pattern[remainder] != "}" {
                remainder = pattern.index(after: remainder)
            }
            if remainder == pattern.endIndex {
                // print("ERROR: unbalanced Choice")
                return false
            }

            // ?? step back
            //   reminder points to the last char AFTER closing curly brace
            remainder = pattern.index(after: remainder)

            // pick first char after opening curly brace
            var char = pattern[pi]
            pi = pattern.index(after: pi)

            while pi < pattern.endIndex {
                if char == "," {
                    if matchComponent(address: address[si...], pattern: pattern[remainder...]) {
                        return true
                    } else {
                        // backtrack on test string
                        si = place
                        // continue testing,
                        // skip comma
                        if pi == pattern.endIndex {
                            return false
                        } else {
                            pi = pattern.index(after: pi)
                        }
                    }
                } else if char == "}" {
                    // continue normal pattern matching
                    if pi == pattern.endIndex && si == address.endIndex {
                        return true
                    }

                    si = address.index(before: si) // str is incremented again below
                } else if char == address[si] {
                    // print("#3 choice: \(char) == \(address[si])")
                    si = address.index(after: si)
                    if si == address.endIndex && remainder < pattern.endIndex {
                        // print("ERROR: address == EOF, pattern != EOF")
                        return false
                    }
                } else { // skip to next comma
                    // reset string position
                    si = place

                    while pi < pattern.endIndex && pattern[pi] != "," && pattern[pi] != "}" {
                        pi = pattern.index(after: pi)
                    }

                    if pi == pattern.endIndex {
                        // print("ERR: UNBALANCED CHOICE")
                        return false
                    }

                    if pattern[pi] == "," {
                        pi = pattern.index(after: pi)
                    } else if pattern[pi] == "}" {
                        return false
                    }
                }

                // --- end of inner switch ---
                char = pattern[pi]
                if pi < pattern.endIndex {
                    pi = pattern.index(after: pi)
                }
            }
        default:
            if char != address[si] {
                return false
            }
        }

        // --- end of outer switch ---

        if si < address.endIndex {
            si = address.index(after: si)
        }

    }

    return si == address.endIndex
}

public func match(address: String, pattern: String) -> Bool {
    let addrComponents: [String] = address.components(separatedBy: "/")
    let patternComponents: [String] = pattern.components(separatedBy: "/")

    // make sure OSC address and patterns have the same number of components
    guard addrComponents.count == patternComponents.count else {
        return false
    }

    return !zip(addrComponents, patternComponents)
        .map { matchComponents(address: $0.0, pattern: $0.1) }
        .contains(false)
}
