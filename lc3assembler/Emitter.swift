//
//  Emitter.swift
//  lc3assembler
//
//  Created by Mert Dümenci on 2/14/17.
//  Copyright © 2017 Mert Dümenci. All rights reserved.
//

import Foundation

protocol BinaryRepresentable {
    func binaryRepresentation() -> NSData
}

struct OpCode {
    let string: String
    let code: UInt8
}

extension Instruction {
    var opcode: OpCode {
        switch self {
        case .ADD:
            return OpCode(string: "ADD", code: 0x1)
        case .ADD_IMMEDIATE:
            return OpCode(string: "ADD", code: 0x1)
        case .AND:
            return OpCode(string: "AND", code: 0x5)
        case .AND_IMMEDIATE:
            return OpCode(string: "AND", code: 0x5)
        case .BR:
            return OpCode(string: "BR", code: 0x0)
        case .JMP:
            return OpCode(string: "JMP", code: 0xC)
        case .JSR:
            return OpCode(string: "JSR", code: 0x4)
        case .JSRR:
            return OpCode(string: "JSRR", code: 0x4)
        case .LD:
            return OpCode(string: "LD", code: 0x2)
        case .LDI:
            return OpCode(string: "LDI", code: 0xA)
        case .LDR:
            return OpCode(string: "LDR", code: 0x6)
        case .LEA:
            return OpCode(string: "LEA", code: 0xE)
        case .NOT:
            return OpCode(string: "NOT", code: 0x9)
        case .RET:
            return OpCode(string: "RET", code: 0xC)
        case .RTI:
            return OpCode(string: "RTI", code: 0x8)
        case .ST:
            return OpCode(string: "ST", code: 0x3)
        case .STI:
            return OpCode(string: "STI", code: 0xB)
        case .STR:
            return OpCode(string: "STR", code: 0x7)
        case .TRAP:
            return OpCode(string: "TRAP", code: 0xF)
        }
    }
}

extension AssemblerDirective: BinaryRepresentable {
    func binaryRepresentation() -> NSData {
        return NSData()
    }
}

extension Instruction: BinaryRepresentable {
    func binaryRepresentation() -> NSData {
        return NSData()
    }
}
