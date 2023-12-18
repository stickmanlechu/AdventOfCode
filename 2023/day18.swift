import Foundation

let input = try! String(contentsOf: URL(fileURLWithPath: "input/day18.txt"), encoding: .utf8).trimmingCharacters(in: .whitespacesAndNewlines)

struct Point: Hashable {
    let x: Int
    let y: Int
}

struct Instruction: Hashable {
    let length: Int
    let direction: Point
}

func originalInstructions() -> [Instruction] {
    input.components(separatedBy: .newlines).filter({ !$0.isEmpty }).map { line in
        let comps = line.components(separatedBy: .whitespaces)
        let vector: Point
        switch comps[0] {
        case "U": vector = .init(x: 0, y: 1)
        case "D": vector = .init(x: 0, y: -1)
        case "L": vector = .init(x: -1, y: 0)
        case "R": vector = .init(x: 1, y: 0)
        default: fatalError()
        }
        return .init(length: Int(comps[1])!, direction: vector)
    }
}

func hexInstructions() -> [Instruction] {
    input.components(separatedBy: .newlines).filter({ !$0.isEmpty }).map { line in
        let hexString = line.components(separatedBy: .whitespaces)[2]
        let trimmed = String(hexString.dropFirst(2).dropLast())
        let length = Int(String(trimmed.dropLast()), radix: 16)!
        let direction: Point
        switch String(trimmed.last!) {
        case "0": direction = .init(x: 1, y: 0)
        case "1": direction = .init(x: 0, y: -1)
        case "2": direction = .init(x: -1, y: 0)
        case "3": direction = .init(x: 0, y: 1)
        default: fatalError()
        }
        return .init(length: length, direction: direction)
    }
}

func solve(shouldUseHexInstructions: Bool) -> Int {
    var digged = [Point(x: 0, y: 0)]
    var current: Point = .init(x: 0, y: 0)
    for instruction in shouldUseHexInstructions ? hexInstructions() : originalInstructions() {
        let end = Point(x: current.x + instruction.direction.x * instruction.length, y: current.y + instruction.direction.y * instruction.length)
        digged.append(end)
        current = end
    }
    var sum = 0
    var onBorder = 0
    for i in digged.indices.dropLast() {
        sum += digged[i].x * digged[i + 1].y - digged[i].y * digged[i + 1].x
        onBorder += abs(digged[i].x - digged[i + 1].x) + abs(digged[i].y - digged[i + 1].y)
    }
    return (abs(sum) / 2) + (onBorder / 2) + 1
}

let start = CFAbsoluteTimeGetCurrent()

print(solve(shouldUseHexInstructions: false))
print(solve(shouldUseHexInstructions: true))

let diff = CFAbsoluteTimeGetCurrent() - start
print("\(#function) Took \(diff) seconds")
