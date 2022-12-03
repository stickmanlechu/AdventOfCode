import Foundation

let input = try! String(contentsOf: URL(fileURLWithPath: "input/day3.txt"), encoding: .utf8)

extension Character {
    var priority: Int {
        guard isUppercase else { return Int(asciiValue!) - 96 }
        return Int(asciiValue!) - 38
    }
}

func solve1() -> Int {
    input.components(separatedBy: "\n")
        .filter { !$0.isEmpty }
        .compactMap { Set($0.prefix($0.count / 2)).intersection(Set($0.suffix($0.count / 2))).first }
        .map(\.priority)
        .reduce(0, +)
}

func solve2() -> Int {
    var lines = input.components(separatedBy: "\n")
        .filter { !$0.isEmpty }
        .map(Set.init)
    
    var prioTotal = 0
    while !lines.isEmpty {
        let three = lines.prefix(3)
        prioTotal += three[0].intersection(three[1]).intersection(three[2]).first!.priority
        lines.removeFirst(3)
    }
    return prioTotal
}

let start = CFAbsoluteTimeGetCurrent()

print(solve2())

let diff = CFAbsoluteTimeGetCurrent() - start
print("\(#function) Took \(diff) seconds")
