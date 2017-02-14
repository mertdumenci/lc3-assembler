//
//  main.swift
//  lc3assembler
//
//  Created by Mert Dümenci on 2/13/17.
//  Copyright © 2017 Mert Dümenci. All rights reserved.
//

import Foundation

let test = ".ORIG x3000\n" +
           "ADD R0, R1, R2\n" +
           "LD R5, VARIABLE\n"

func parseTest(test: String) {
    let assemblyFile = parse(assembly: test)
    let assembledLines: [BinaryRepresentable]? = assemblyFile?.map() { $0.assembly }
    
    print(assembledLines as Any)
}

parseTest(test: test)
