//
//  Parser.swift
//  lc3assembler
//
//  Created by Mert Dümenci on 2/13/17.
//  Copyright © 2017 Mert Dümenci. All rights reserved.
//

import Foundation

let space: Character = " "

func tokenize(line: String) -> [String] {
    return line.characters.split(separator: space).map() { sequence in
        return String(sequence).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
}

struct ConditionCode: OptionSet {
    let rawValue: Int
    
    static let negative = (1 << 2)
    static let zero = (1 << 1)
    static let positive = (1 << 0)
}

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

protocol BinaryRepresentable {
    func data() -> NSData
}

enum AssemblerDirective {
    case COMMENT(comment: String)
    case ORIG(address: UInt16)
    case FILL(data: UInt16)
    case BLKW(length: UInt)
    case STRINGZ(string: String)
    case END
    
    var opcode: String {
        switch self {
        case .COMMENT:
            return ";"
        case .ORIG:
            return ".ORIG"
        case .FILL:
            return ".FILL"
        case .BLKW:
            return ".BLKW"
        case .STRINGZ:
            return ".STRINGZ"
        case .END:
            return ".END"
        }
    }
    
    static var opcodes: [String] {
        // TODO: I hate this -- find a better (?) way of initializing all cases
        let allDirectives: [AssemblerDirective] =
            [.COMMENT(comment: String()), .ORIG(address: 0), .FILL(data: 0), .BLKW(length: 0), .STRINGZ(string: String()), .END]
        return allDirectives.map() { $0.opcode }
    }
}

extension AssemblerDirective: BinaryRepresentable {
    func data() -> NSData {
        return NSData() // TODO: Implement
    }
}

extension AssemblerDirective {
    func parse(line: String) -> AssemblerDirective? {
        let tokens = tokenize(line: line)
        
        let opcode: String
        let operands: ArraySlice<String>
        
        if let first = tokens.first, AssemblerDirective.opcodes.contains(first) {
            opcode = first
            operands = tokens[1..<tokens.count]
        } else if tokens.count > 1, AssemblerDirective.opcodes.contains(tokens[1]) {
            opcode = tokens[1]
            operands = tokens[2..<tokens.count]
        } else {
            return nil
        }
        
        switch opcode {
        case ";":
            let comment = operands.joined(separator: String(space))
            return .COMMENT(comment: comment)
        case ".ORIG":
            guard operands.count == 1, let address = UInt16(operands[0]) else {
                return nil
            }
            
            return .ORIG(address: address)
        case ".FILL":
            guard operands.count == 1, let data = UInt16(operands[0]) else { // TODO: Implement proper integer parsing (#x)
                return nil
            }
            
            return .FILL(data: data)
        case ".BLKW":
            guard operands.count == 1, let length = UInt(operands[0]) else {
                return nil
            }
        
            return .BLKW(length: length)
        case ".STRINGZ":
            let string = operands.joined(separator: String(space)) // TODO: Implement parsing string in quotes
            return .STRINGZ(string: string)
        case ".END":
            return .END
        default:
            return nil
        }
    }
}

enum Instruction {
    case ADD(dataRegister: UInt8, sourceRegister1: UInt8, sourceRegister2: UInt8)
    case ADD_IMMEDIATE(dataRegister: UInt8, sourceRegister: UInt8, immediateValue: Int8)
    case AND(dataRegister: UInt8, sourceRegister1: UInt8, sourceRegister2: UInt8)
    case AND_IMMEDIATE(dataRegister: UInt8, sourceRegister: UInt8, immediateValue: Int8)
    case BR(conditionCode: ConditionCode, offset: Resolvable<UInt16>)
    case JMP(baseRegister: UInt8)
    case JSR(offset: Resolvable<UInt16>)
    case JSRR(baseRegister: UInt8)
    case LD(dataRegister: UInt8, offset: Resolvable<UInt16>)
    case LDI(dataRegister: UInt8, offset: Resolvable<UInt16>)
    case LDR(dataRegister: UInt8, baseRegister: UInt8, offset: Resolvable<UInt16>)
    case LEA(dataRegister: UInt8, offset: Resolvable<UInt16>)
    case NOT(dataRegister: UInt8, sourceRegister: UInt8)
    case RET
    case RTI
    case ST(sourceRegister: UInt8, offset: Resolvable<UInt16>)
    case STI(sourceRegister: UInt8, offset: Resolvable<UInt16>)
    case STR(sourceRegister: UInt8, baseRegister: UInt8, offset: Resolvable<UInt16>)
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

extension Instruction: BinaryRepresentable {
    func data() -> NSData {
        return NSData() // TODO: Implement
    }
}
