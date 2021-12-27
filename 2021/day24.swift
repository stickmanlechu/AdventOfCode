import Foundation

enum Register: String, CaseIterable {
    case w, x, y, z
}

enum RegisterOrValue {
    case register(Register)
    case value(Int)
    
    static func from(_ string: String) -> Self {
        guard let reg = Register(rawValue: string) else {
            return .value(Int(string)!)
        }
        return .register(reg)
    }
}

enum Instruction {
    case inp(Register)
    case add(Register, RegisterOrValue)
    case mul(Register, RegisterOrValue)
    case div(Register, RegisterOrValue)
    case mod(Register, RegisterOrValue)
    case eql(Register, RegisterOrValue)
    
    static func from(_ string: String) -> Instruction {
        let comps = string.split(separator: " ").map(String.init)
        let targetRegister = Register(rawValue: comps[1])!
        switch comps[0] {
        case "inp":
            return .inp(targetRegister)
        case "add":
            return .add(targetRegister, .from(comps[2]))
        case "mul":
            return .mul(targetRegister, .from(comps[2]))
        case "div":
            return .div(targetRegister, .from(comps[2]))
        case "mod":
            return .mod(targetRegister, .from(comps[2]))
        case "eql":
            return .eql(targetRegister, .from(comps[2]))
        default:
            fatalError("Unrecognized instruction")
        }
    }
}

final class ALU {
    var registers: [Register: Int] = [:]
    var instructions: [Instruction] = []
    
    func execute(_ input: [Int]) -> Int? {
        var inputDigits = input
        for instruction in instructions {
            switch instruction {
            case .inp(let register):
                registers[register] = inputDigits.popLast()!
            case .add(let register, let registerOrValue):
                registers[register, default: 0] += value(from: registerOrValue)
            case .mul(let register, let registerOrValue):
                registers[register, default: 0] *= value(from: registerOrValue)
            case .div(let register, let registerOrValue):
                let val = value(from: registerOrValue)
                guard val != 0 else { return nil }
                registers[register, default: 0] /= val
            case .mod(let register, let registerOrValue):
                guard registers[register, default: 0] >= 0 else { return nil }
                let val = value(from: registerOrValue)
                guard val > 0 else { return nil }
                registers[register, default: 0] %= val
            case .eql(let register, let registerOrValue):
                registers[register, default: 0] = registers[register, default: 0] == value(from: registerOrValue) ? 1 : 0
            }
        }
        return registers[.z]
    }
    
    func printRegisters() {
        print(Register.allCases.map { registers[$0, default: 0] })
    }
    
    func reset() {
        registers.removeAll()
    }
    
    private func value(from registerOrValue: RegisterOrValue) -> Int {
        switch registerOrValue {
        case .register(let reg):
            return registers[reg, default: 0]
        case .value(let val):
            return val
        }
    }
}

func solve(_ input: String) {
    var instructionSets: [[Instruction]] = []
    input
        .split(separator: "\n")
        .map(String.init)
        .map(Instruction.from(_:))
        .forEach { instruction in
            switch instruction {
            case .inp:
                instructionSets.append([instruction])
            default:
                instructionSets[instructionSets.count - 1].append(instruction)
            }
        }
    // added for memory optimization - 16GB of RAM was not enough :<
    instructionSets[12] = instructionSets[12] + instructionSets.remove(at: 13)
    let alu = ALU()
    var solutions: [Int: [String]] = [0: [""]]
    for lvl in instructionSets.indices {
        alu.instructions = instructionSets[lvl]
        findSolutions(with: &solutions, using: alu, level: lvl)
    }
    guard let nums = solutions[0] else { return }
    print(nums.min() ?? "no min")
    print(nums.max() ?? "no max")
}

func findSolutions(with currentSolutions: inout [Int: [String]], using alu: ALU, level: Int) {
    var newSolutions = [Int: [String]]()
    for pair in currentSolutions {
        for i in 1...9 {
            alu.reset()
            alu.registers[.z] = pair.key
            solutions(with: &newSolutions, previous: pair.value, using: alu, input: [i], level: level)
        }
        currentSolutions[pair.key] = nil
    }
    currentSolutions = newSolutions
}

func solutions(with newSolutions: inout [Int: [String]], previous: [String], using alu: ALU, input: [Int], level: Int) {
    guard level == 12 else {
        let idx = alu.execute(input)!
        guard idx < 200000 else { return } // trial and error
        newSolutions[idx] = newSolutions[idx, default: []] + previous.map { $0 + String(input[0]) }
        return
    }
    // added for memory optimization - 16GB of RAM was not enough :<
    let registers = alu.registers
    for i in 1...9 {
        alu.registers = registers
        let idx = alu.execute([i] + input)!
        guard idx == 0 else { continue }
        newSolutions[idx] = newSolutions[idx, default: []] + previous.map { $0 + String(input[0]) + String(i) }
    }
}

let start = CFAbsoluteTimeGetCurrent()

let input = (try! String(contentsOf: URL(fileURLWithPath: "input/day24.txt"), encoding: .utf8)).trimmingCharacters(in: .whitespacesAndNewlines)
solve(input)

let diff = CFAbsoluteTimeGetCurrent() - start
print("\(#function) Took \(diff) seconds")
