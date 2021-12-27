import Foundation

struct Point: Hashable {
    let row: Int
    let col: Int
    
    var adjacent: [Point] {
        [.init(row: row - 1, col: col), .init(row: row + 1, col: col), .init(row: row, col: col - 1), .init(row: row, col: col + 1)]
    }
    
    func within(_ heightMap: [[Int]]) -> Bool {
        let columnCount = heightMap[0].count
        let rowCount = heightMap.count
        return row >= 0 && col >= 0 && row < rowCount && col < columnCount
    }
}

func riskLevel(in heightMap: [[Int]]) -> Int {
    let columnCount = heightMap[0].count
    let rowCount = heightMap.count
    return heightMap.indices.reduce(0) { partialResult, row in
        partialResult + heightMap[row].indices.reduce(0) { partialResult, col in
            let val = heightMap[row][col]
            guard val != 9 else { return partialResult }
            let adjacent = [(row - 1, col), (row + 1, col), (row, col - 1), (row, col + 1)].filter { $0.0 >= 0 && $0.0 < rowCount && $0.1 >= 0 && $0.1 < columnCount }
            guard adjacent.allSatisfy({ heightMap[$0.0][$0.1] > val }) else { return partialResult }
            return partialResult + 1 + val
        }
    }
}

func basinSize(for point: Point, in heightMap: [[Int]], alreadyProcessed: inout Set<Point>) -> Int {
    guard !alreadyProcessed.contains(point),
          point.within(heightMap),
          heightMap[point.row][point.col] < 9 else {
              return 0
          }
    alreadyProcessed.insert(point)
    return 1 + point.adjacent.map { basinSize(for: $0, in: heightMap, alreadyProcessed: &alreadyProcessed) }.reduce(0, +)
}

func basinScore(for heightMap: [[Int]]) -> Int {
    var alreadyProcessed: Set<Point> = []
    return heightMap.indices
        .flatMap { row in
            heightMap[row].indices.map { col in
                Point(row: row, col: col)
            }
        }
        .compactMap {
            !alreadyProcessed.contains($0) ? basinSize(for: $0, in: heightMap, alreadyProcessed: &alreadyProcessed) : nil
        }
        .sorted()
        .suffix(3)
        .reduce(1, *)
}

let input = (try! String(contentsOf: URL(fileURLWithPath: "input/day9.txt"), encoding: .utf8)).trimmingCharacters(in: .whitespacesAndNewlines)

let heightMap = input.split(separator: "\n")
    .map { row in row.map { Int(String($0))! } }

let start = CFAbsoluteTimeGetCurrent()

//print(riskLevel(in: heightMap))
print(basinScore(for: heightMap))

let diff = CFAbsoluteTimeGetCurrent() - start
print("\(#function) Took \(diff) seconds")
