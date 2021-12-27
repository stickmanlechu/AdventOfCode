// https://adventofcode.com/2021/day/2

import Foundation

let input = try! String(contentsOf: URL(fileURLWithPath: "input/day2.txt"), encoding: .utf8)

enum Command {
    case forward(Int)
    case up(Int)
    case down(Int)
    
    init(_ string: String) {
        let comps = string.split(separator: " ")
        let value = Int(comps[1])!
        switch comps[0] {
        case "forward": self = .forward(value)
        case "up": self = .up(value)
        case "down": self = .down(value)
        default: fatalError()
        }
    }
}

func solve1(_ commands: [Command]) -> Int {
    let coordinates = commands.reduce((depth: 0, forward: 0)) { result, command in
        switch command {
        case .forward(let value): return (depth: result.depth, forward: result.forward + value)
        case .up(let value): return (depth: result.depth - value, forward: result.forward)
        case .down(let value): return (depth: result.depth + value, forward: result.forward)
        }
    }
    return coordinates.depth * coordinates.forward
}

func solve2(_ commands: [Command]) -> Int {
    let coordinates = commands.reduce((depth: 0, forward: 0, aim: 0)) { result, command in
        switch command {
        case .forward(let value): return (depth: result.depth + value * result.aim, forward: result.forward + value, aim: result.aim)
        case .up(let value): return (depth: result.depth, forward: result.forward, aim: result.aim - value)
        case .down(let value): return (depth: result.depth, forward: result.forward, aim: result.aim + value)
        }
    }
    return coordinates.depth * coordinates.forward
}

let commands = input
    .split(separator: "\n")
    .map(String.init)
    .map(Command.init)

let start = CFAbsoluteTimeGetCurrent()

//print(solve1(commands))
print(solve2(commands))

let diff = CFAbsoluteTimeGetCurrent() - start
print("\(#function) Took \(diff) seconds")

