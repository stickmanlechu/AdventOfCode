import Foundation

func play(_ numbers: [Int], rounds: Int = 100) -> [Int: Int] {
    var cups = [Int: Int]()
    numbers.indices.dropFirst().forEach { cups[numbers[$0 - 1]] = numbers[$0] }
    cups[numbers.last!] = numbers[0]
    let maxValue = cups.values.max()!
    var chosen = numbers.first!
    for _ in 1...rounds {
        let removed = (1...2).reduce(into: [cups[chosen]!]) { partialResult, _ in
            partialResult.append(cups[partialResult.last!]!)
        }
        cups[chosen] = cups[removed.last!]
        removed.forEach { cups[$0] = nil }
        var destination = chosen
        repeat {
            destination = (destination - 1) == 0 ? maxValue : destination - 1
        } while cups[destination] == nil
        let next = cups[destination]!
        for ins in removed {
            cups[destination] = ins
            destination = ins
        }
        cups[destination] = next
        chosen = cups[chosen]!
    }
    return cups
}

func solve1(_ input: String) -> String {
    let numbers = input.map { Int(String($0))! }
    let cups = play(numbers)
    var retString = ""
    var current = cups[1]!
    while current != 1 {
        retString.append(String(current))
        current = cups[current]!
    }
    return retString
}

func solve2(_ input: String) -> Int {
    let numbers = input.map { Int(String($0))! } + (10...1000000)
    let cups = play(numbers, rounds: 10000000)
    return cups[1]! * cups[cups[1]!]!
}

let input = "315679824"

let start = CFAbsoluteTimeGetCurrent()

print(solve2(input))

let diff = CFAbsoluteTimeGetCurrent() - start
print("\(#function) Took \(diff) seconds")
