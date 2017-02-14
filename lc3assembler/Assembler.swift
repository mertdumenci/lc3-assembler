//
//  Assembler.swift
//  lc3assembler
//
//  Created by Mert Dümenci on 2/13/17.
//  Copyright © 2017 Mert Dümenci. All rights reserved.
//

import Foundation

struct Resolvable<T> {
    let value: T?
    let symbol: String?
    
    func resolve(table: SymbolTable?) -> T? { // TODO: throws unresolvable error
        if let value = value {
            return value
        }
        
        // TODO: resolve symbol
        return nil
    }
}

struct SymbolTable {
    
}

struct Assembler {
    
}

func generate(assembly: NSData) -> SymbolTable? {
    return nil
}

func assemble(assembly: NSData) -> NSData? {
    return nil
}
