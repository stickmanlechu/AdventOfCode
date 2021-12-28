import Foundation

typealias SeatMap = [[Character]]

extension SeatMap {
    func countNeighbors(of row: Int, col: Int, firstVisible: Bool) -> Int {
        guard firstVisible else { return countClosestNeighbors(of: row, col: col) }
        return [
            (-1, -1),
            (-1, 0),
            (-1, 1),
            (0, -1),
            (0, 1),
            (1, -1),
            (1, 0),
            (1, 1),
        ].reduce(0) { partialResult, coords in
            partialResult + countFirstVisible(from: row, col: col, rowChange: coords.0, colChange: coords.1)
        }
    }
    
    func countFirstVisible(from row: Int, col: Int, rowChange: Int, colChange: Int) -> Int {
        let newRow = row + rowChange
        let newCol = col + colChange
        guard newRow >= 0 && newRow < count else { return 0 }
        guard newCol >= 0 && newCol < self[newRow].count else { return 0 }
        switch self[newRow][newCol] {
        case "#": return 1
        case "L": return 0
        default: return countFirstVisible(from: newRow, col: newCol, rowChange: rowChange, colChange: colChange)
        }
    }
    
    func countClosestNeighbors(of row: Int, col: Int) -> Int {
        [
            (row - 1, col - 1),
            (row - 1, col),
            (row - 1, col + 1),
            (row, col - 1),
            (row, col + 1),
            (row + 1, col - 1),
            (row + 1, col),
            (row + 1, col + 1),
        ].reduce(0) { partialResult, coords in
            guard coords.0 >= 0 && coords.0 < count else { return partialResult }
            guard coords.1 >= 0 && coords.1 < self[coords.0].count else { return partialResult }
            return partialResult + (self[coords.0][coords.1] == "#" ? 1 : 0)
        }
    }
    
    func countTaken() -> Int {
        reduce(0) { partialResult, row in
            partialResult + row.reduce(0, { partialResult, char in
                return partialResult + (char == "#" ? 1 : 0)
            })
        }
    }
}

func iterate(_ seatMap: SeatMap, seatTolerance: Int, firstVisible: Bool) -> SeatMap {
    var newMap = seatMap
    for row in seatMap.indices {
        for col in seatMap[row].indices {
            switch seatMap[row][col] {
            case "L":
                guard seatMap.countNeighbors(of: row, col: col, firstVisible: firstVisible) == 0 else { continue }
                newMap[row][col] = "#"
            case "#":
                guard seatMap.countNeighbors(of: row, col: col, firstVisible: firstVisible) >= seatTolerance else { continue }
                newMap[row][col] = "L"
            default: continue
            }
        }
    }
    return newMap
}

func solve(_ seatMap: SeatMap, seatTolerance: Int = 4, firstVisible: Bool = false) -> Int {
    var seatMap = seatMap
    while true {
        let newMap = iterate(seatMap, seatTolerance: seatTolerance, firstVisible: firstVisible)
        guard newMap != seatMap else {
            return seatMap.countTaken()
        }
        seatMap = newMap
    }
}

let input = try! String(contentsOf: URL(fileURLWithPath: "input/day11.txt"), encoding: .utf8)
let seatingMap = input
    .trimmingCharacters(in: .whitespacesAndNewlines)
    .components(separatedBy: "\n")
    .map(Array.init)

let start = CFAbsoluteTimeGetCurrent()

print(solve(seatingMap, seatTolerance: 5, firstVisible: true))

let diff = CFAbsoluteTimeGetCurrent() - start
print("\(#function) Took \(diff) seconds")


