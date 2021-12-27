import Foundation

func toInt<T: Sequence>(_ bytes: T) -> Int where T.Element == Int {
    bytes.reversed().enumerated().reduce(0) { result, byte in result + (1 << byte.offset) * byte.element }
}

extension Character {
    var int: Int {
        switch self {
        case ".": return 0
        case "#": return 1
        default: fatalError()
        }
    }
}

typealias Image = [[Int]]

extension Array {
    var extendedIndices: ClosedRange<Int> {
        return (indices.startIndex - 1)...(indices.endIndex + 1)
    }
}

extension Image {
    var visual: String {
        map { row in
            row.map { $0 == 0 ? "." : "#" }.joined()
        }.joined(separator: "\n")
    }
    
    // using iteration % 2 as algorithm[0] = 1 and algorithm.last == 0
    // and it's easier this way :)
    subscript(row: Int, col: Int, iteration: Int) -> Int {
        get {
            if row < 0 || row >= count { return iteration % 2 }
            if col < 0 || col >= self[row].count { return iteration % 2 }
            return self[row][col]
        }
    }
    
    func enhanced(with algorithm: [Int], iteration: Int) -> Image {
        var newImage = Image()
        for row in extendedIndices {
            var newRow = [Int]()
            for col in self[0].extendedIndices {
                let around = ((row - 1)...(row + 1)).flatMap {
                    r in ((col - 1)...(col + 1)).map { c -> Int in self[r, c, iteration] }
                }
                let algorithmIndex = toInt(around)
                newRow.append(algorithm[algorithmIndex])
            }
            newImage.append(newRow)
        }
        return newImage
    }
    
    func countLit() -> Int {
        (0..<count).map { self[$0].reduce(0, +) }.reduce(0, +)
    }
}

let input = (try! String(contentsOf: URL(fileURLWithPath: "input/day20.txt"), encoding: .utf8)).trimmingCharacters(in: .whitespacesAndNewlines)
let rows = input
    .split(separator: "\n")
    .map(String.init)

let algorithm: [Int] = rows.first!.map(\.int)
let image: Image = rows
    .dropFirst()
    .map { $0.map(\.int) }

let start = CFAbsoluteTimeGetCurrent()

var current = image
(0..<50).forEach { i in
    current = current.enhanced(with: algorithm, iteration: i)
    if [1, 49].contains(i) { print(current.countLit()) }
}

let diff = CFAbsoluteTimeGetCurrent() - start
print("\(#function) Took \(diff) seconds")
