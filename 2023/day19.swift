import Foundation

let input = try! String(contentsOf: URL(fileURLWithPath: "input/day19.txt"), encoding: .utf8).trimmingCharacters(in: .whitespacesAndNewlines)

struct Workflow: Hashable {
    let instructions: [Instruction]
    let defaultGoTo: String?
    
    static func from(_ str: String) -> Workflow {
        var instructions = [Instruction]()
        for instructionStr in str.components(separatedBy: ",") {
            if let instruction = Instruction.from(instructionStr) {
                instructions.append(instruction)
            } else {
                return .init(instructions: instructions, defaultGoTo: instructionStr)
            }
        }
        return .init(instructions: instructions, defaultGoTo: nil)
    }
    
    func run(part: [Int]) -> String {
        for instruction in instructions {
            if instruction.greaterThan && part[instruction.partIndex] > instruction.value {
                return instruction.target
            }
            if !instruction.greaterThan && part[instruction.partIndex] < instruction.value {
                return instruction.target
            }
        }
        return defaultGoTo!
    }
}

struct Instruction: Hashable {
    let target: String
    let partIndex: Int
    let greaterThan: Bool
    let value: Int
    
    static func from(_ str: String) -> Instruction? {
        let comps = str.components(separatedBy: ":")
        guard comps.count == 2 else { return nil }
        let target = comps[1]
        var condition = comps[0]
        let first = String(condition.removeFirst())
        let partIndex = ["x", "m", "a", "s"].firstIndex(of: first)!
        let greaterThan = condition.removeFirst() == Character(">")
        let value = Int(condition)!
        return .init(target: target, partIndex: partIndex, greaterThan: greaterThan, value: value)
    }
}

func ranges(for key: String, workflows: [String: Workflow], inputRanges: [ClosedRange<Int>]) -> [[ClosedRange<Int>]] {
    if key == "R" { return [] }
    if key == "A" { return [inputRanges] }
    var result = [[ClosedRange<Int>]]()
    var inputRanges = inputRanges
    for instruction in workflows[key]!.instructions {
        let range = inputRanges[instruction.partIndex]
        if instruction.greaterThan {
            if range.upperBound < instruction.value { continue }
            if range.lowerBound > instruction.value {
                result.append(contentsOf: ranges(for: instruction.target, workflows: workflows, inputRanges: inputRanges))
                return result
            }
            var newRanges = inputRanges
            newRanges[instruction.partIndex] = (instruction.value + 1)...range.upperBound
            result.append(contentsOf: ranges(for: instruction.target, workflows: workflows, inputRanges: newRanges))
            inputRanges[instruction.partIndex] = inputRanges[instruction.partIndex].clamped(to: 1...instruction.value)
        } else {
            if range.lowerBound > instruction.value { continue }
            if range.upperBound < instruction.value {
                result.append(contentsOf: ranges(for: instruction.target, workflows: workflows, inputRanges: inputRanges))
                return result
            }
            var newRanges = inputRanges
            newRanges[instruction.partIndex] = range.lowerBound...(instruction.value - 1)
            result.append(contentsOf: ranges(for: instruction.target, workflows: workflows, inputRanges: newRanges))
            inputRanges[instruction.partIndex] = inputRanges[instruction.partIndex].clamped(to: instruction.value...4000)
        }
    }
    if let def = workflows[key]?.defaultGoTo {
        result.append(contentsOf: ranges(for: def, workflows: workflows, inputRanges: inputRanges))
    }
    return result
}

func solve1(workflows: [String: Workflow], partString: String) -> Int {
    var totalAccepted = 0
    for part in partString.components(separatedBy: .newlines) where !part.isEmpty {
        let nums = part.replacingOccurrences(of: "[^0-9,]", with: "", options: .regularExpression).components(separatedBy: ",").compactMap(Int.init)
        var flow = "in"
        while true {
            if flow == "R" { break }
            if flow == "A" {
                totalAccepted += nums.reduce(0, +)
                break
            }
            flow = workflows[flow]!.run(part: nums)
        }
    }
    return totalAccepted
}

func solve2(workflows: [String: Workflow]) -> Int {
    ranges(for: "in", workflows: workflows, inputRanges: [1...4000, 1...4000, 1...4000, 1...4000])
        .filter { !$0.isEmpty }
        .map {
            $0.map(\.count).reduce(1, *)
        }
        .reduce(0, +)
}

let start = CFAbsoluteTimeGetCurrent()

let comps = input.components(separatedBy: "\n\n")
let workflows = comps[0].components(separatedBy: .newlines).reduce(into: [String: Workflow]()) { all, line in
    let wString = line.dropLast().components(separatedBy: "{")
    all[wString[0]] = Workflow.from(wString[1])
}

print(solve1(workflows: workflows, partString: comps[1]))
print(solve2(workflows: workflows))

let diff = CFAbsoluteTimeGetCurrent() - start
print("\(#function) Took \(diff) seconds")
