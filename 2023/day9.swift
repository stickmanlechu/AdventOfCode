import Foundation

let input = try! String(contentsOf: URL(fileURLWithPath: "input/day9.txt"), encoding: .utf8)

func solve(numbers: [Int]) -> (Int, Int) {
    if numbers.allSatisfy({ $0 == 0 }) { return (0, 0) }
    let diffs = solve(numbers: numbers.indices.dropFirst().map { numbers[$0] - numbers[$0 - 1] })
    return (numbers.first! - diffs.0, numbers.last! + diffs.1)
}

let start = CFAbsoluteTimeGetCurrent()

let rows = input.components(separatedBy: .newlines)
    .filter { !$0.isEmpty }
    .map { line in
        line.components(separatedBy: .whitespaces).compactMap(Int.init)
    }

let final = rows.map(solve).reduce((0, 0)) {
    ($0.0 + $1.0, $0.1 + $1.1)
}

print(final)

let diff = CFAbsoluteTimeGetCurrent() - start
print("\(#function) Took \(diff) seconds")
