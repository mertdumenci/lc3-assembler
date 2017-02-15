//
//  Parser.swift
//  lc3assembler
//
//  Created by Mert Dümenci on 2/13/17.
//  Copyright © 2017 Mert Dümenci. All rights reserved.
//

import Foundation

func parseHex(string: String) -> UInt16? {
    guard let first = string.characters.first, first == "x" else {
        return nil
    }
    
    let strippedString = strip(string, of: ",")
    
    let secondIndex = strippedString.index(strippedString.startIndex, offsetBy: 1)
    return UInt16(strippedString.substring(from: secondIndex), radix: 16)
}

func parseInt(string: String) -> Int16? {
    guard let first = string.characters.first, first == "#" else {
        return nil
    }
    
    let strippedString = strip(string, of: ",")
    
    let secondIndex = strippedString.index(strippedString.startIndex, offsetBy: 1)
    return Int16(strippedString.substring(from: secondIndex))
}

func parseNumber(string: String) -> Int16? {
    if let hex = parseHex(string: string) {
        return Int16(hex)
    } else {
        return parseInt(string: string)
    }
}

func parseResolvable(string: String) -> Resolvable<UInt16> {
    if let value = parseNumber(string: string) {
        return Resolvable(value: UInt16(value), symbol: nil)
    }
    
    let strippedString = strip(string, of: ",")
    
    return Resolvable(value: nil, symbol: strippedString)
}

func parseRegister(string: String) -> UInt8? {
    guard let first = string.characters.first, first == "R" else {
        return nil
    }
    
    let strippedString = strip(string, of: ",")
    
    let secondIndex = strippedString.index(strippedString.startIndex, offsetBy: 1)
    guard let int = UInt8(strippedString.substring(from: secondIndex)),
        int >= 0 || int < 8 else {
        return nil
    }
    
    return int
}

func deconsBR(opcode: String) -> (opcode: String, conditionCode: ConditionCode)? {
    var firstTwo = opcode
    
    if firstTwo.characters.count < 3 {
        if firstTwo == "BR" {
            return (firstTwo, [])
        }
        
        return nil
    }
    
    let thirdIndex = opcode.index(opcode.startIndex, offsetBy: 3)
    firstTwo = opcode.substring(to: thirdIndex)
    
    if firstTwo != "BR" {
        return nil
    }
    
    let rest = opcode.substring(from: thirdIndex)
    var conditionCode: ConditionCode = []
    
    if rest.contains("n") {
        conditionCode.insert(.negative)
    }
    
    if rest.contains("z") {
        conditionCode.insert(.zero)
    }
    
    if rest.contains("p") {
        conditionCode.insert(.positive)
    }
    
    return (firstTwo, conditionCode)
}

struct ConditionCode: OptionSet {
    let rawValue: Int
    
    static let negative = ConditionCode(rawValue: 1 << 2)
    static let zero = ConditionCode(rawValue: 1 << 1)
    static let positive = ConditionCode(rawValue: 1 << 0)
}

struct Assembly<T> {
    let assembly: T
    let label: String?
    let address: UInt16
}

extension Assembly where T: BinaryRepresentable {
    func binaryRepresentation() -> NSData {
        return NSData()
    }
}

extension Assembly: CustomStringConvertible {
    var description: String {
        return "Assembly (\(printHex(address)), \(label)): \(assembly)"
    }
}

typealias LabeledLine = (label: String?, line: String)

enum AssemblerDirective {
    case COMMENT(comment: String)
    case ORIG(address: UInt16)
    case FILL(data: UInt16)
    case BLKW(length: UInt)
    case STRINGZ(string: String)
    case END
    
    static let opcodes =
        [";", ".ORIG", ".FILL", ".BLKW", ".STRINGZ", ".END"]
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
    
    static let opcodes =
        ["ADD", "AND", "BR", "JMP", "JSR", "JSRR", "LD", "LDI", "LDR", "LEA", "NOT",
         "RET", "RTI", "ST", "STI", "STR", "TRAP"]
}

protocol Parseable {
    static func parse(line: LabeledLine, address: UInt16) -> Assembly<BinaryRepresentable>? // TODO: Don't use Assembly<T> here, extract that part to a separate function
}

extension AssemblerDirective: Parseable {
    static func parse(line: LabeledLine, address: UInt16) -> Assembly<BinaryRepresentable>? {
        let tokens = tokenize(line: line.line)
        
        guard let opcode = tokens.first, AssemblerDirective.opcodes.contains(opcode) else {
            return nil
        }
        
        let rest = tokens[1..<tokens.count]
        var directive: AssemblerDirective? = nil
        
        switch opcode {
        case ";":
            let content = rest.joined(separator: " ")
            directive = .COMMENT(comment: content)
    
        case ".ORIG":
            if let address = parseNumber(string: rest[1]) {
                directive = .ORIG(address: UInt16(address))
            }
            
        case ".FILL":
            if let data = parseNumber(string: rest[1]) {
                directive = .FILL(data: UInt16(data))
            }
            
        case ".BLKW":
            fatalError(".BLKW not implemented")
            
        case ".STRINGZ":
            fatalError(".STRINGZ not implemented")
            
        case ".END":
            directive = .END
            
        default:
            break
        }
        
        if let directive = directive {
            return Assembly(assembly: directive, label: line.label, address: address)
        }
        
        return nil
    }
}

extension Instruction: Parseable {
    static func parse(line: LabeledLine, address: UInt16) -> Assembly<BinaryRepresentable>? {
        let tokens = tokenize(line: line.line)
        
        guard let opcode = tokens.first, Instruction.opcodes.contains(opcode) else {
            return nil
        }
        
        let rest = tokens[1..<tokens.count]
        var instruction: Instruction? = nil
        
        switch opcode {
        case "ADD":
            if let dataRegister = parseRegister(string: rest[1]),
                let sourceRegister1 = parseRegister(string: rest[2]),
                let sourceRegister2 = parseRegister(string: rest[3]) {
                
                instruction = .ADD(dataRegister: dataRegister,
                                   sourceRegister1: sourceRegister1,
                                   sourceRegister2: sourceRegister2)
            }

            else if let dataRegister = parseRegister(string: rest[1]),
                let sourceRegister = parseRegister(string: rest[2]),
                let immediateValue = parseInt(string: rest[3]) {
                
                instruction = .ADD_IMMEDIATE(dataRegister: dataRegister,
                                             sourceRegister: sourceRegister,
                                             immediateValue: Int8(immediateValue))
            }
        
        case "AND":
            if let dataRegister = parseRegister(string: rest[1]),
                let sourceRegister1 = parseRegister(string: rest[2]),
                let sourceRegister2 = parseRegister(string: rest[3]) {
                
                instruction = .AND(dataRegister: dataRegister,
                                   sourceRegister1: sourceRegister1,
                                   sourceRegister2: sourceRegister2)
            }
                
            else if let dataRegister = parseRegister(string: rest[1]),
                let sourceRegister = parseRegister(string: rest[2]),
                let immediateValue = parseInt(string: rest[3]) {
                
                instruction = .AND_IMMEDIATE(dataRegister: dataRegister,
                                             sourceRegister: sourceRegister,
                                             immediateValue: Int8(immediateValue))
            }
            
        // Special case for BR, as the branch conditions are inside the opcode
        // i.e. BRn, BRnzp, BRz, BR, etc.
        case _ where deconsBR(opcode: opcode) != nil: // TODO: I don't like the 2x calls to deconsBR
            let br = deconsBR(opcode: opcode)!
            let offset = parseResolvable(string: rest[1])
            
            instruction = .BR(conditionCode: br.conditionCode, offset: offset)
            
        case "JMP":
            if let baseRegister = parseRegister(string: rest[1]) {
                instruction = .JMP(baseRegister: baseRegister)
            }
            
        case "JSR":
            let offset = parseResolvable(string: rest[1])
            instruction = .JSR(offset: offset)
            
        case "JSRR":
            if let baseRegister = parseRegister(string: rest[1]) {
                instruction = .JSRR(baseRegister: baseRegister)
            }
            
        case "LD":
            if let dataRegister = parseRegister(string: rest[1]) {
                let offset = parseResolvable(string: rest[2])
                instruction = .LD(dataRegister: dataRegister, offset: offset)
            }
            
        case "LDI":
            if let dataRegister = parseRegister(string: rest[1]) {
                let offset = parseResolvable(string: rest[2])
                instruction = .LDI(dataRegister: dataRegister, offset: offset)
            }
            
        case "LDR":
            if let dataRegister = parseRegister(string: rest[1]),
                let baseRegister = parseRegister(string: rest[2]) {
                let offset = parseResolvable(string: rest[3])
                instruction = .LDR(dataRegister: dataRegister,
                                   baseRegister: baseRegister,
                                   offset: offset)
            }
            
        case "LEA":
            if let dataRegister = parseRegister(string: rest[1]) {
                let offset = parseResolvable(string: rest[2])
                
                instruction = .LEA(dataRegister: dataRegister,
                                   offset: offset)
            }
            
        case "NOT":
            if let dataRegister = parseRegister(string: rest[1]),
                let sourceRegister = parseRegister(string: rest[2]) {
                instruction = .NOT(dataRegister: dataRegister, sourceRegister: sourceRegister)
            }
            
        case "RET":
            instruction = .RET
            
        case "RTI":
            instruction = .RTI
            
        case "ST":
            if let sourceRegister = parseRegister(string: rest[1]) {
                let offset = parseResolvable(string: rest[2])
                instruction = .ST(sourceRegister: sourceRegister,
                                  offset: offset)
            }
            
        case "STI":
            if let sourceRegister = parseRegister(string: rest[1]) {
                let offset = parseResolvable(string: rest[2])
                instruction = .STI(sourceRegister: sourceRegister,
                                   offset: offset)
            }
            
        case "STR":
            if let sourceRegister = parseRegister(string: rest[1]),
                let baseRegister = parseRegister(string: rest[2]) {
                let offset = parseResolvable(string: rest[3])
                instruction = .STR(sourceRegister: sourceRegister,
                                   baseRegister: baseRegister,
                                   offset: offset)
            }
        
        case "TRAP":
            if let trapVector = parseNumber(string: rest[1]) {
                instruction = .TRAP(trapVector: UInt8(trapVector))
            }
            
        default:
            break
        }
        
        if let instruction = instruction {
            return Assembly(assembly: instruction, label: line.label, address: address)
        }
        
        return nil
    }
}

func stripLabel(_ line: String) -> LabeledLine {
    let tokens = tokenize(line: line)
    
    // There can't be a label if there's 0 or 1 tokens
    if tokens.count < 2 {
        return (nil, line)
    }
    
    let possibleOpcodes = AssemblerDirective.opcodes + Instruction.opcodes
    
    // If the first token is an opcode, return early: there's no label
    guard let first = tokens.first, !possibleOpcodes.contains(first) else {
        return (nil, line)
    }
    
    return (first, tokens[1..<tokens.count].joined(separator: " "))
}

func parse(assembly: String) -> [Assembly<BinaryRepresentable>]? {
    let lines = assembly.characters.split(separator: "\n").map { String($0) }
    
    var assembly: [Assembly<BinaryRepresentable>] = []
    var initialAddress: UInt16? = nil
    var counter: UInt16 = 0
    
    for line in lines {
        if let directive = AssemblerDirective.parse(line: stripLabel(line), address: 0x0),
            case .ORIG(let address) = (directive.assembly as! AssemblerDirective)  { // TODO: Find a way that doesn't need a force cast
            initialAddress = address
        }
    }
    
    if let initialAddress = initialAddress {
        for line in lines {
            let address = initialAddress + counter
            
            let instruction = Instruction.parse(line: stripLabel(line), address: address)
            let directive = AssemblerDirective.parse(line: stripLabel(line), address: address)
            
            if let instruction = instruction {
                assembly.append(instruction)
            } else if let directive = directive {
                assembly.append(directive)
            } else {
                fatalError("Can't parse line: " + line)
            }
            
            counter += 1
        }
    }
    
    return (assembly.count == 0 ? nil : assembly)
}
