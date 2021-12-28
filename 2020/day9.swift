import Foundation

func solve1(_ numbers: [Int]) -> Int {
    let first25 = numbers.prefix(25)
    var sets = first25.indices.map { i in
        Set(first25.dropFirst(i + 1).map { $0 + first25[i] })
    }
    for index in numbers.indices.dropFirst(25) {
        let num = numbers[index]
        guard sets.first(where: { $0.contains(num) }) != nil else { return num }
        sets.remove(at: 0)
        sets.indices.forEach {
            sets[$0].insert(numbers[index - 24 + $0] + num)
        }
        sets.append([])
    }
    fatalError()
}

func solve2(_ numbers: [Int]) -> Int {
    let num = solve1(numbers)
    for i in numbers.indices {
        var sum = numbers[i]
        var cns = [sum]
        for j in (i + 1)..<numbers.endIndex {
            sum += numbers[j]
            cns.append(numbers[j])
            if sum > num { break }
            guard sum == num && cns.count > 1 else { continue }
            return cns.min()! + cns.max()!
        }
    }
    fatalError()
}

let input = try! String(contentsOf: URL(fileURLWithPath: "input/day9.txt"), encoding: .utf8)
let numbers = input
    .trimmingCharacters(in: .whitespacesAndNewlines)
    .components(separatedBy: "\n")
    .map { Int($0)! }

let start = CFAbsoluteTimeGetCurrent()

print(solve2(numbers))

let diff = CFAbsoluteTimeGetCurrent() - start
print("\(#function) Took \(diff) seconds")
