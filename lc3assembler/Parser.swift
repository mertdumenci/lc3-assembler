//
//  Parser.swift
//  lc3assembler
//
//  Created by Mert Dümenci on 2/13/17.
//  Copyright © 2017 Mert Dümenci. All rights reserved.
//

import Foundation

struct ConditionCode: OptionSet {
    let rawValue: Int
    
    static let negative = (1 << 0)
    static let zero = (1 << 1)
    static let positive = (1 << 2)
}

enum Instruction {
    case ADD(dataRegister: UInt8, sourceRegister1: UInt8, sourceRegister2: UInt8)
    case ADD_IMMEDIATE(dataRegister: UInt8, sourceRegister: UInt8, immediateValue: UInt8)
    case AND(dataRegister: UInt8, sourceRegister1: UInt8, sourceRegister2: UInt8)
    case AND_IMMEDIATE(dataRegister: UInt8, sourceRegister: UInt8, immediateValue: UInt8)
    case BR(conditionCode: ConditionCode, offset: UInt8)
    case JMP(baseRegister: UInt8)
    case JSR(offset: UInt16)
    case JSRR(baseRegister: UInt8)
    case LD(dataRegister: UInt8, offset: UInt8)
    case LDI(dataRegister: UInt8, offset: UInt8)
    case LDR(dataRegister: UInt8, baseRegister: UInt8, offset: UInt8)
    case LEA(dataRegister: UInt8, offset: UInt8)
    case NOT(dataRegister: UInt8, sourceRegister: UInt8)
    case RET
    case RTI
    case ST(sourceRegister: UInt8, offset: UInt8)
    case STI(sourceRegister: UInt8, offset: UInt8)
    case STR(sourceRegister: UInt8, baseRegister: UInt8, offset: UInt8)
    case TRAP(trapVector: UInt8)
    
    var opCode: UInt8 {
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
