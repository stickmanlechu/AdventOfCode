import Foundation

enum Instruction {
    case jmp(Int)
    case acc(Int)
    case nop(Int)
    
    static func from(_ str: String) -> Instruction {
        let comps = str.replacingOccurrences(of: "+", with: "").components(separatedBy: " ")
        switch comps[0] {
        case "jmp":
            return .jmp(Int(comps[1])!)
        case "acc":
            return .acc(Int(comps[1])!)
        case "nop":
            return .nop(Int(comps[1])!)
        default:
            fatalError()
        }
    }
}

func run(instructions: [Instruction], returnAccOnLoop: Bool = true) -> Int? {
    var accumulator = 0
    var index = 0
    var alreadyVisited = Set<Int>()
    while index < instructions.count {
        guard alreadyVisited.insert(index).inserted else {
            return returnAccOnLoop ? accumulator : nil
        }
        switch instructions[index] {
        case .acc(let value):
            accumulator += value
            index += 1
        case .nop:
            index += 1
        case .jmp(let value):
            index += value
        }
    }
    return accumulator
}

func solve1(_ instructions: [Instruction]) -> Int {
    run(instructions: instructions)!
}

func solve2(_ instructions: [Instruction]) -> Int {
    for index in instructions.indices {
        switch instructions[index] {
        case .acc:
            continue
        case .jmp(let value):
            var newInstructions = instructions
            newInstructions[index] = .nop(value)
            if let a = run(instructions: newInstructions, returnAccOnLoop: false) {
                return a
            }
        case .nop(let value):
            var newInstructions = instructions
            newInstructions[index] = .jmp(value)
            if let a = run(instructions: newInstructions, returnAccOnLoop: false) {
                return a
            }
        }
    }
    fatalError()
}

let input = try! String(contentsOf: URL(fileURLWithPath: "input/day8.txt"), encoding: .utf8)
let instructions = input
    .trimmingCharacters(in: .whitespacesAndNewlines)
    .components(separatedBy: "\n")
    .map(Instruction.from(_:))

let start = CFAbsoluteTimeGetCurrent()

//print(solve1(instructions))
print(solve2(instructions))

let diff = CFAbsoluteTimeGetCurrent() - start
print("\(#function) Took \(diff) seconds")

