//
//  Helpers.swift
//  lc3assembler
//
//  Created by Mert Dümenci on 2/14/17.
//  Copyright © 2017 Mert Dümenci. All rights reserved.
//

import Foundation

let space: Character = " "

func tokenize(line: String) -> [String] {
    return line.characters.split(separator: space).map() { sequence in
        return String(sequence).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
}

func strip(_ string: String, of: String) -> String {
    return string.replacingOccurrences(of: of, with: "")
}

func printHex(_ integer: UInt16) -> String {
    return "0x" + String(integer, radix: 16)
}
