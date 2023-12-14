import Foundation

let input = try! String(contentsOf: URL(fileURLWithPath: "input/day14.txt"), encoding: .utf8)

struct Rock: Hashable {
    var row: Int
    var col: Int
}

func solve1(rollingRocks: inout Set<Rock>, staticRocks: Set<Rock>) {
    for var rollingRock in rollingRocks.sorted(by: { $0.row < $1.row }) {
        rollingRocks.remove(rollingRock)
        while rollingRock.row > 0 {
            let moved = Rock(row: rollingRock.row - 1, col: rollingRock.col)
            guard !rollingRocks.contains(moved) && !staticRocks.contains(moved) else { break }
            rollingRock = moved
        }
        rollingRocks.insert(rollingRock)
    }
}

func solve2(rollingRocks: inout Set<Rock>, staticRocks: Set<Rock>, maxRow: Int, maxCol: Int) {
    var setInCycle = [Set<Rock>: Int]()
    for cycle in 1...100000 {
        //north
        for var rollingRock in rollingRocks.sorted(by: { $0.row < $1.row }) {
            rollingRocks.remove(rollingRock)
            while rollingRock.row > 0 {
                let moved = Rock(row: rollingRock.row - 1, col: rollingRock.col)
                guard !rollingRocks.contains(moved) && !staticRocks.contains(moved) else { break }
                rollingRock = moved
            }
            rollingRocks.insert(rollingRock)
        }
        //west
        for var rollingRock in rollingRocks.sorted(by: { $0.col < $1.col }) {
            rollingRocks.remove(rollingRock)
            while rollingRock.col > 0 {
                let moved = Rock(row: rollingRock.row, col: rollingRock.col - 1)
                guard !rollingRocks.contains(moved) && !staticRocks.contains(moved) else { break }
                rollingRock = moved
            }
            rollingRocks.insert(rollingRock)
        }
        //south
        for var rollingRock in rollingRocks.sorted(by: { $0.row > $1.row }) {
            rollingRocks.remove(rollingRock)
            while rollingRock.row < maxRow - 1 {
                let moved = Rock(row: rollingRock.row + 1, col: rollingRock.col)
                guard !rollingRocks.contains(moved) && !staticRocks.contains(moved) else { break }
                rollingRock = moved
            }
            rollingRocks.insert(rollingRock)
        }
        //east
        for var rollingRock in rollingRocks.sorted(by: { $0.col > $1.col }) {
            rollingRocks.remove(rollingRock)
            while rollingRock.col < maxCol - 1 {
                let moved = Rock(row: rollingRock.row, col: rollingRock.col + 1)
                guard !rollingRocks.contains(moved) && !staticRocks.contains(moved) else { break }
                rollingRock = moved
            }
            rollingRocks.insert(rollingRock)
        }
        guard let firstCycle = setInCycle[rollingRocks] else {
            setInCycle[rollingRocks] = cycle
            continue
        }
        let cycleLength = cycle - firstCycle
        let delta = (1000000000 - firstCycle) / cycleLength
        let properCycle = 1000000000 - (delta * cycleLength)
        rollingRocks = setInCycle.first(where: { $0.value == properCycle })!.key
        break
    }
}

let start = CFAbsoluteTimeGetCurrent()

var rollingRocks = Set<Rock>()
var staticRocks = Set<Rock>()
let allLines = input.components(separatedBy: .newlines).filter({ !$0.isEmpty })
let maxRow = allLines.count
let maxCol = allLines[0].count
for (row, line) in allLines.enumerated() {
    for (col, char) in line.enumerated() {
        switch char {
        case "O": rollingRocks.insert(.init(row: row, col: col))
        case "#": staticRocks.insert(.init(row: row, col: col))
        default: continue
        }
    }
}

//solve1(rollingRocks: &rollingRocks, staticRocks: staticRocks)
solve2(rollingRocks: &rollingRocks, staticRocks: staticRocks, maxRow: maxRow, maxCol: maxCol)
let result = rollingRocks.map { allLines.count - $0.row }
    .reduce(0, +)
print(result)

let diff = CFAbsoluteTimeGetCurrent() - start
print("\(#function) Took \(diff) seconds")
