//
//  main.swift
//  lc3assembler
//
//  Created by Mert Dümenci on 2/13/17.
//  Copyright © 2017 Mert Dümenci. All rights reserved.
//

import Foundation

let test = ".ORIG x3000\n" +
           "START ADD R0, R1, R2\n" +
           "LD R5, VARIABLE\n" +
           "VARIABLE .FILL #9\n" +
           "STI R7, START\n" +
           "BRnz START\n" +
           ".END"

func parseTest(test: String) {
    let assembly = assemble(assemblyFile: test)
    print(assembly as Any)
}

parseTest(test: test)
