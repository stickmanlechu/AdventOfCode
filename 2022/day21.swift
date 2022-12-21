import Foundation

let input = try! String(contentsOf: URL(fileURLWithPath: "input/day21.txt"), encoding: .utf8)

enum Action {
    case add(String, String)
    case sub(String, String)
    case mul(String, String)
    case div(String, String)
    
    static func from(_ string: String) -> Action {
        if string.contains("+") {
            let comps = string.components(separatedBy: " + ")
            return .add(comps[0], comps[1])
        }
        if string.contains("-") {
            let comps = string.components(separatedBy: " - ")
            return .sub(comps[0], comps[1])
        }
        if string.contains("*") {
            let comps = string.components(separatedBy: " * ")
            return .mul(comps[0], comps[1])
        }
        if string.contains("/") {
            let comps = string.components(separatedBy: " / ")
            return .div(comps[0], comps[1])
        }
        fatalError()
    }
}

var monkeyAction: [String: Action] = [:]
var monkeyValue: [String: Int] = [:]

for line in input.components(separatedBy: "\n").filter({ !$0.isEmpty }) {
    let comps = line.components(separatedBy: ": ")
    if comps[1].count < 4 {
        monkeyValue[comps[0]] = Int(comps[1])!
    } else {
        monkeyAction[comps[0]] = Action.from(comps[1])
    }
}

func calc(_ monkey: String) -> Int {
    if let value = monkeyValue[monkey] { return value }
    switch monkeyAction[monkey]! {
    case let .add(monkey1, monkey2):
        monkeyValue[monkey] = calc(monkey1) + calc(monkey2)
    case let .sub(monkey1, monkey2):
        monkeyValue[monkey] = calc(monkey1) - calc(monkey2)
    case let .mul(monkey1, monkey2):
        monkeyValue[monkey] = calc(monkey1) * calc(monkey2)
    case let .div(monkey1, monkey2):
        monkeyValue[monkey] = calc(monkey1) / calc(monkey2)
    }
    return monkeyValue[monkey]!
}

var monkeyHasHumanInSubTree = [String: Bool]()

func hasHuman(_ monkey: String) -> Bool {
    switch monkeyAction[monkey] {
    case let .add(monkey1, monkey2):
        monkeyHasHumanInSubTree[monkey] = hasHuman(monkey1) || hasHuman(monkey2)
    case let .sub(monkey1, monkey2):
        monkeyHasHumanInSubTree[monkey] = hasHuman(monkey1) || hasHuman(monkey2)
    case let .mul(monkey1, monkey2):
        monkeyHasHumanInSubTree[monkey] = hasHuman(monkey1) || hasHuman(monkey2)
    case let .div(monkey1, monkey2):
        monkeyHasHumanInSubTree[monkey] = hasHuman(monkey1) || hasHuman(monkey2)
    case nil:
        monkeyHasHumanInSubTree[monkey] = monkey == "humn"
    }
    return monkeyHasHumanInSubTree[monkey]!
}

func solve2() -> Int {
    guard case let .add(monkey1, monkey2) = monkeyAction["root"] else { fatalError() }
    _ = hasHuman("root")
    let monkeyWithHuman = monkeyHasHumanInSubTree[monkey1]! ? monkey1 : monkey2
    let seekedValue = monkeyHasHumanInSubTree[monkey1]! ? calc(monkey2) : calc(monkey1)
    return solve2(monkey: monkeyWithHuman, result: seekedValue)
}

func solve2(monkey: String, result: Int) -> Int {
    switch monkeyAction[monkey] {
    case let .add(monkey1, monkey2):
        let monkeyWithHuman = monkeyHasHumanInSubTree[monkey1, default: false] ? monkey1 : monkey2
        let valueForCalculableMonkey = monkeyHasHumanInSubTree[monkey1, default: false] ? calc(monkey2) : calc(monkey1)
        return solve2(monkey: monkeyWithHuman, result: result - valueForCalculableMonkey)
    case let .sub(monkey1, monkey2):
        let monkeyWithHuman = monkeyHasHumanInSubTree[monkey1, default: false] ? monkey1 : monkey2
        let valueForCalculableMonkey = monkeyHasHumanInSubTree[monkey1, default: false] ? calc(monkey2) : calc(monkey1)
        return solve2(monkey: monkeyWithHuman, result: monkeyWithHuman == monkey1 ? (result + valueForCalculableMonkey) : (valueForCalculableMonkey - result))
    case let .mul(monkey1, monkey2):
        let monkeyWithHuman = monkeyHasHumanInSubTree[monkey1, default: false] ? monkey1 : monkey2
        let valueForCalculableMonkey = monkeyHasHumanInSubTree[monkey1, default: false] ? calc(monkey2) : calc(monkey1)
        return solve2(monkey: monkeyWithHuman, result: result / valueForCalculableMonkey)
    case let .div(monkey1, monkey2):
        let monkeyWithHuman = monkeyHasHumanInSubTree[monkey1, default: false] ? monkey1 : monkey2
        let valueForCalculableMonkey = monkeyHasHumanInSubTree[monkey1, default: false] ? calc(monkey2) : calc(monkey1)
        return solve2(monkey: monkeyWithHuman, result: monkeyWithHuman == monkey1 ? (result * valueForCalculableMonkey) : (valueForCalculableMonkey / result))
    case nil: // humn
        return result
    }
}

let startTime = CFAbsoluteTimeGetCurrent()

//print(calc("root"))
print(solve2())

let diff = CFAbsoluteTimeGetCurrent() - startTime
print("\(#function) Took \(diff) seconds")
