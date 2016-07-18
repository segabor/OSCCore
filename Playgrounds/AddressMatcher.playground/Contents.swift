//: Playground - noun: a place where people can play

import Cocoa


/*
 */
func matches(address: String, pattern: String) -> Bool {
    var negate = false
    // var match = false
    
    var si = address.startIndex
    var pi = pattern.startIndex
    
    while pi < pattern.endIndex {
        // si == address.endIndex && pattern[pi] != "*" return false
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
                if matches(address: address.substring(from: si), pattern: pattern.substring(from:pi)) {
                    return true
                }
            }

            return false
            
//            break
        case "?":
            if si < address.endIndex {
                break
            }
 
            return false
            
//            break
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
                let c = pattern[pi]
                pi = pattern.index(after: pi)
                
                // detect range
                // case c-c
                if c == "-" {
                    // skip char
                    pi = pattern.index(after: pi)
                    if pi == pattern.endIndex {
                        return false
                    }

                    if pattern[pi] != "]" {
                        if address[si] == c || address[si] == pattern[pi]
                            || (address[si] > c && address[si] < pattern[pi]) {
                            match = true
                        }
                    } else { // c-]
                        if address[si] >= c {
                            match = true
                        }
                        break
                    }
                } else {
                    // cc or c]
                    if c == address[si] {
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
            
            // FIXME : negate result
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
            
            break
        case "{":
            
            let place = si // to backtrack
            var remainder = pi
            
            // find the end of the brace list
            while remainder < pattern.endIndex && pattern[remainder] != "}" {
                remainder = pattern.index(after:remainder)
            }
            if remainder == pattern.endIndex {
                return false
            }
            
            remainder = pattern.index(after:remainder)

            
            var char = pattern[pi]
            pi = pattern.index(after:pi)
            while pi < pattern.endIndex {
                if char == "," {
                    // TBD
                } else if char == "}" {
                    // TBD
                } else if char == address[si] {
                    // TBD
                } else { // skip to next comma
                    // TBD
                }
                
                // end of while
                char = pattern[pi]
                pi = pattern.index(after:pi)
            }

            
            
            
            break
        default:
            if char != address[si] {
                return false
            }

            break
        }
        
    }
    
    return false
}
