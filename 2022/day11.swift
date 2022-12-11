import Foundation

let input = try! String(contentsOf: URL(fileURLWithPath: "input/day11.txt"), encoding: .utf8)

enum Operation {
    case sq
    case add(Int)
    case mul(Int)
}

final class Monkey {
    var items: [Int] = []
    var operation: Operation?
    var divisibleBy: Int = 0
    var trueMonkeyIndex = -1
    var falseMonkeyIndex = -1
    var timesInspected = 0
}

func parseMonkeys() -> [Monkey] {
    var monkeyIndex = 0
    var monkeys: [Monkey] = []
    for line in input.components(separatedBy: "\n").filter({ !$0.isEmpty }).map({ $0.trimmingCharacters(in: .whitespaces) }) {
        if line.starts(with: "Monkey") {
            monkeyIndex = Int(line.components(separatedBy: " ")[1].dropLast())!
            monkeys.append(Monkey())
        } else if line.starts(with: "Starting items") {
            monkeys[monkeyIndex].items = line.replacingOccurrences(of: "Starting items: ", with: "").replacingOccurrences(of: " ", with: "").components(separatedBy: ",").compactMap(Int.init)
        } else if line.starts(with: "Test") {
            monkeys[monkeyIndex].divisibleBy = Int(line.replacingOccurrences(of: "Test: divisible by ", with: ""))!
        } else if line.starts(with: "If true") {
            monkeys[monkeyIndex].trueMonkeyIndex = Int(line.replacingOccurrences(of: "If true: throw to monkey ", with: ""))!
        } else if line.starts(with: "If false") {
            monkeys[monkeyIndex].falseMonkeyIndex = Int(line.replacingOccurrences(of: "If false: throw to monkey ", with: ""))!
        } else if line.starts(with: "Operation") {
            let comps = line.replacingOccurrences(of: "Operation: new = old ", with: "").components(separatedBy: " ")
            if comps[0] == "+" {
                monkeys[monkeyIndex].operation = .add(Int(comps[1])!)
            } else if comps[0] == "*" && comps[1] == "old" {
                monkeys[monkeyIndex].operation = .sq
            } else {
                monkeys[monkeyIndex].operation = .mul(Int(comps[1])!)
            }
        }
    }
    return monkeys
}

func round(monkeys: inout [Monkey], divisor: Int, advancedWorrying: Bool) {
    for monkey in monkeys {
        let items = monkey.items
        monkey.items = []
        for item in items {
            monkey.timesInspected += 1
            var newVal = item
            switch monkey.operation! {
            case .add(let int):
                newVal += int
            case .mul(let int):
                newVal *= int
            case .sq:
                newVal *= item
            }
            if advancedWorrying {
                newVal %= divisor
            } else {
                newVal /= divisor
            }
            if newVal % monkey.divisibleBy == 0 {
                monkeys[monkey.trueMonkeyIndex].items.append(newVal)
            } else {
                monkeys[monkey.falseMonkeyIndex].items.append(newVal)
            }
        }
    }
}

func monkeyBusiness(after rounds: Int, advancedWorrying: Bool) -> Int {
    var monkeys = parseMonkeys()
    let divisor = advancedWorrying ? monkeys.map(\.divisibleBy).reduce(1, *) : 3
    for _ in 0..<rounds {
        round(monkeys: &monkeys, divisor: divisor, advancedWorrying: advancedWorrying)
    }
    let sortedMonkeyValues = monkeys.map(\.timesInspected).sorted()
    return sortedMonkeyValues[monkeys.count - 2] * sortedMonkeyValues[monkeys.count - 1]
}

func solve1() -> Int {
    monkeyBusiness(after: 20, advancedWorrying: false)
}

func solve2() -> Int {
    monkeyBusiness(after: 10000, advancedWorrying: true)
}

let start = CFAbsoluteTimeGetCurrent()

print(solve2())

let diff = CFAbsoluteTimeGetCurrent() - start
print("\(#function) Took \(diff) seconds")
