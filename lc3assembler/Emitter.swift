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

extension Instruction {
    var opcode: UInt8 {
        switch self {
        case .ADD:
            return 0x1
        case .ADD_IMMEDIATE:
            return 0x1
        case .AND:
            return 0x5
        case .AND_IMMEDIATE:
            return 0x5
        case .BR:
            return 0x0
        case .JMP:
            return 0xC
        case .JSR:
            return 0x4
        case .JSRR:
            return 0x4
        case .LD:
            return 0x2
        case .LDI:
            return 0xA
        case .LDR:
            return 0x6
        case .LEA:
            return 0xE
        case .NOT:
            return 0x9
        case .RET:
            return 0xC
        case .RTI:
            return 0x8
        case .ST:
            return 0x3
        case .STI:
            return 0xB
        case .STR:
            return 0x7
        case .TRAP:
            return 0xF
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
