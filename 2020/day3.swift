import Foundation

let input = try! String(contentsOf: URL(fileURLWithPath: "input/day3.txt"), encoding: .utf8)
let rows = input
    .split(separator: "\n")
    .map(String.init)
    .map(Array.init)

extension Array where Element == [Character] {
    func numberOfTreesTraversing(rowInc: Int = 1, colInc: Int) -> Int {
        var row = 0
        var col = 0
        var sum = 0
        while true {
            row += rowInc
            guard row < count else { break }
            col = (col + colInc) % self[row].count
            guard self[row][col] == "#" else { continue }
            sum += 1
        }
        return sum
    }
}

func solve1() -> Int {
    return rows.numberOfTreesTraversing(rowInc: 1, colInc: 3)
}

func solve2() -> Int {
    [(1, 1), (1, 3), (1, 5), (1, 7), (2, 1)].reduce(1) {
        $0 * rows.numberOfTreesTraversing(rowInc: $1.0, colInc: $1.1)
    }
}

let start = CFAbsoluteTimeGetCurrent()

//print(solve1())
print(solve2())

let diff = CFAbsoluteTimeGetCurrent() - start
print("\(#function) Took \(diff) seconds")

