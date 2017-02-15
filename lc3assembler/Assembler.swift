//
//  Assembler.swift
//  lc3assembler
//
//  Created by Mert Dümenci on 2/13/17.
//  Copyright © 2017 Mert Dümenci. All rights reserved.
//

import Foundation

typealias SymbolTable = Dictionary<String, UInt16>

struct ResolvableOffset {
    var value: Int16?
    let symbol: String?
    
    func resolving(table: SymbolTable?, currentAddress: UInt16)
                    -> ResolvableOffset? {
        if let value = value {
            return ResolvableOffset(value: value, symbol: nil)
        }
    
        if let table = table,
           let symbol = symbol,
           let symbolAddress = table[symbol] {
            let offset = Int16(symbolAddress) - Int16(currentAddress + 1)
            return ResolvableOffset(value: offset, symbol: nil)
        }
        
        return nil
    }
}

extension ResolvableOffset: CustomStringConvertible {
    var description: String {
        if let value = value {
            return String(value)
        } else if let symbol = symbol {
            return symbol
        }
        
        return "Empty resolvable"
    }
}


func generate(assemblyFile: String) -> ([Assembly<BinaryRepresentable>], SymbolTable)? {
    guard let assembly = parse(assembly: assemblyFile) else {
        return nil
    }
    
    var table: SymbolTable = SymbolTable()
    for line in assembly {
        if let label = line.label {
            table[label] = line.address
        }
    }
    
    return (assembly, table)
}

func resolveSymbols(assembly: [Assembly<BinaryRepresentable>],
                    table: SymbolTable) -> [Assembly<BinaryRepresentable>] {
    var resolvedAssembly = Array<Assembly<BinaryRepresentable>>()
    
    for line in assembly {
        if let instruction = line.assembly as? Instruction {
            let resolvedInstruction: Instruction
            
            switch instruction {
            case .BR(let conditionCode, let offset):
                if let resolved =
                    offset.resolving(table: table,
                                     currentAddress: line.address) {
                    resolvedInstruction = .BR(conditionCode: conditionCode,
                                              offset: resolved)
                } else {
                    fatalError("Can't resolve symbol")
                }
            case .JSR(let offset):
                if let resolved =
                    offset.resolving(table: table,
                                     currentAddress: line.address) {
                    resolvedInstruction = .JSR(offset: resolved)
                } else {
                    fatalError("Can't resolve symbol")
                }
            case .LD(let dataRegister, let offset):
                if let resolved =
                    offset.resolving(table: table,
                                     currentAddress: line.address) {
                    resolvedInstruction = .LD(dataRegister: dataRegister,
                                              offset: resolved)
                } else {
                    fatalError("Can't resolve symbol")
                }
            case .LDI(let dataRegister, let offset):
                if let resolved =
                    offset.resolving(table: table,
                                     currentAddress: line.address) {
                    resolvedInstruction = .LDI(dataRegister: dataRegister,
                                               offset: resolved)
                } else {
                    fatalError("Can't resolve symbol")
                }
            case .LDR(let dataRegister, let baseRegister, let offset):
                if let resolved =
                    offset.resolving(table: table,
                                     currentAddress: line.address) {
                    resolvedInstruction = .LDR(dataRegister: dataRegister,
                                              baseRegister: baseRegister,
                                              offset: resolved)
                } else {
                    fatalError("Can't resolve symbol")
                }
            case .LEA(let dataRegister, let offset):
                if let resolved =
                    offset.resolving(table: table,
                                     currentAddress: line.address) {
                    resolvedInstruction = .LEA(dataRegister: dataRegister,
                                               offset: resolved)
                } else {
                    fatalError("Can't resolve symbol")
                }
            case .ST(let sourceRegister, let offset):
                if let resolved =
                    offset.resolving(table: table,
                                     currentAddress: line.address) {
                    resolvedInstruction = .ST(sourceRegister: sourceRegister,
                                              offset: resolved)
                } else {
                    fatalError("Can't resolve symbol")
                }
            case .STI(let sourceRegister, let offset):
                if let resolved =
                    offset.resolving(table: table,
                                     currentAddress: line.address) {
                    resolvedInstruction = .STI(sourceRegister: sourceRegister,
                                              offset: resolved)
                } else {
                    fatalError("Can't resolve symbol")
                }
            case .STR(let sourceRegister, let baseRegister, let offset):
                if let resolved =
                    offset.resolving(table: table,
                                     currentAddress: line.address) {
                    resolvedInstruction = .STR(sourceRegister: sourceRegister,
                                               baseRegister: baseRegister,
                                               offset: resolved)
                } else {
                    fatalError("Can't resolve symbol")
                }
            default:
                resolvedInstruction = instruction
            }
            
            let resolvedLine = Assembly<BinaryRepresentable>(assembly: resolvedInstruction,
                                                             label: line.label,
                                                             address: line.address)
            
            resolvedAssembly.append(resolvedLine)
        } else {
            resolvedAssembly.append(line)
        }
    }
    
    return resolvedAssembly
}

func assemble(assemblyFile: String) -> [Assembly<BinaryRepresentable>]? {
    let unresolved = generate(assemblyFile: test)
    
    if let assembly = unresolved?.0, let table = unresolved?.1 {
        return resolveSymbols(assembly: assembly, table: table)
    }
    
    return nil
}
