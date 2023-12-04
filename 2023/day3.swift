import Foundation

let input = try! String(contentsOf: URL(fileURLWithPath: "input/day3.txt"), encoding: .utf8)

struct SymbolPosition {
    let symbol: String
    let position: Int
}

struct NumberPosition: Hashable {
    let number: Int
    let start: Int
    let end: Int
    
    func neighbors(rows: Int) -> Set<Int> {
        Set((start...end).flatMap { $0.neighbors(rows: rows) })
    }
}

extension Int {
    func neighbors(rows: Int) -> [Int] {
        let row = self / rows
        let col = self % rows
        return [(row - 1, col - 1), (row - 1, col), (row - 1, col + 1),
                (row, col - 1), (row, col + 1),
                (row + 1, col - 1), (row + 1, col), (row + 1, col + 1)]
            .filter {
                $0.0 >= 0 && $0.0 < rows && $0.1 >= 0 && $0.1 < rows
            }
            .map {
                $0.0 * rows + $0.1
            }
    }
}

func solve1(symbols: [SymbolPosition], numbers: [NumberPosition], rowLength: Int) -> Int {
    let symbolPositions = Set(symbols.map(\.position))
    return numbers
        .filter {
            !$0.neighbors(rows: rowLength).intersection(symbolPositions).isEmpty
        }
        .reduce(0) {
            $0 + $1.number
        }
}

func solve2(symbols: [SymbolPosition], numbers: [NumberPosition], rowLength: Int) -> Int {
    let potentialGears = symbols.filter { $0.symbol == "*" }
    var sum = 0
    let numberNeighbors = numbers.reduce(into: [NumberPosition: Set<Int>]()) {
        $0[$1] = Set(($1.start...$1.end))
    }
    for potentialGear in potentialGears {
        let neighbors = potentialGear.position.neighbors(rows: rowLength)
        let matchingNumbers = numbers.filter { number in
            !numberNeighbors[number]!.intersection(neighbors).isEmpty
        }
        guard matchingNumbers.count == 2 else { continue }
        sum += matchingNumbers.map(\.number).reduce(1, *)
    }
    return sum
}

let start = CFAbsoluteTimeGetCurrent()

let numberRegex = try! Regex("[0-9]+")
let symbolRegex = try! Regex("[^0-9.\n]?")
let rowLength = input.components(separatedBy: "\n")[0].count
let fullInput = input.replacingOccurrences(of: "\n", with: "")
let numbers: [NumberPosition] = fullInput.matches(of: numberRegex).map { match -> NumberPosition in
        .init(number: Int(fullInput[match.range])!,
              start: fullInput.distance(from: fullInput.startIndex, to: match.range.lowerBound),
              end: fullInput.distance(from: fullInput.startIndex, to: match.range.upperBound) - 1)
}
let symbols: [SymbolPosition] = fullInput.matches(of: symbolRegex).compactMap { match -> SymbolPosition? in
    let symbol = fullInput[match.range]
    guard !symbol.isEmpty else { return nil }
    return .init(symbol: String(symbol), position: fullInput.distance(from: fullInput.startIndex, to: match.range.lowerBound))
}

//print(solve1(symbols: symbols, numbers: numbers, rowLength: rowLength))
print(solve2(symbols: symbols, numbers: numbers, rowLength: rowLength))

let diff = CFAbsoluteTimeGetCurrent() - start
print("\(#function) Took \(diff) seconds")
