import Foundation

let input = try! String(contentsOf: URL(fileURLWithPath: "input/day8.txt"), encoding: .utf8)

extension Int {
    static let primes: Set<Int> = {
        var primes = Set<Int>(2...999999)
        for prime in 2...999999 where primes.contains(prime) {
            stride(from: prime + prime, to: 1000000, by: prime).forEach { primes.remove($0) }
        }
        return primes
    }()
    
    func primeDivisors() -> [Int] {
        let divisors = (1...Int(sqrt(Double(self)))).filter { self % $0 == 0 }
        return divisors.flatMap { $0 == 1 ? [1] : [$0, self / $0] }
    }
}

func solve(instructions: [String], map: [String: (String, String)], start: String = "AAA", end: Set<String> = ["ZZZ"]) -> Int  {
    var currentKey = start
    var currentInstructionIndex = -1
    var steps = 0
    while !end.contains(currentKey) {
        steps += 1
        currentInstructionIndex = (currentInstructionIndex + 1) % instructions.count
        switch instructions[currentInstructionIndex] {
        case "R": currentKey = map[currentKey]!.1
        case "L": currentKey = map[currentKey]!.0
        default: fatalError()
        }
    }
    return steps
}

func solve2(instructions: [String], map: [String: (String, String)]) -> Int {
    let currentKeys = map.keys.filter { $0[$0.index(before: $0.endIndex)] == "A" }
    let ends = Set(map.keys.filter { $0[$0.index(before: $0.endIndex)] == "Z" })
    return Set(currentKeys
        .map {
            solve(instructions: instructions, map: map, start: $0, end: ends)
        }
        .flatMap { $0.primeDivisors() })
        .reduce(1, *)
}

let start = CFAbsoluteTimeGetCurrent()

let lines = input.components(separatedBy: "\n").filter { !$0.isEmpty }
let instructions = lines[0].map(String.init)
let map = lines.dropFirst()
    .reduce(into: [String: (String, String)]()) { partialResult, line in
        let comps = line.components(separatedBy: " = ")
        let paths = comps[1].dropFirst().dropLast().components(separatedBy: ", ")
        partialResult[comps[0]] = (paths[0], paths[1])
    }
//print(solve(instructions: instructions, map: map))
print(solve2(instructions: instructions, map: map))

let diff = CFAbsoluteTimeGetCurrent() - start
print("\(#function) Took \(diff) seconds")
