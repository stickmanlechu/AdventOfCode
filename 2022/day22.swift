import Foundation

let input = try! String(contentsOf: URL(fileURLWithPath: "input/day22.txt"), encoding: .utf8)

enum Operation {
    case go(Int)
    case rotateR
    case rotateL
    
    var str: String {
        switch self {
        case .rotateL: return "left"
        case .rotateR: return "right"
        case .go(let val): return "go \(val)"
        }
    }
}

let lines = input.components(separatedBy: "\n").filter({ !$0.isEmpty })
let mapLines = lines.dropLast()
let mapWidth = mapLines.map(\.count).max()!
var map = mapLines.map { line -> [Int] in
    let chars = Array(line)
    return (0..<mapWidth).map {
        let char = $0 >= chars.count ? " " : chars[$0]
        switch char {
        case " ": return 0
        case ".": return 1
        case "#": return Int.max
        default: fatalError()
        }
    }
}
var operations = [Operation]()
var stack = ""
for char in Array(lines.last!) {
    guard char.isLetter else {
        stack.append(char)
        continue
    }
    if !stack.isEmpty {
        operations.append(.go(Int(stack)!))
        stack = ""
    }
    switch char {
    case "R": operations.append(.rotateR)
    case "L": operations.append(.rotateL)
    default: fatalError()
    }
}
if !stack.isEmpty {
    operations.append(.go(Int(stack)!))
}

func solve1() -> Int {
    var col = map[0].firstIndex(of: 1)!
    var row = 0
    let orientations = [(row: 0, col: 1), (row: 1, col: 0), (row: 0, col: -1), (row: -1, col: 0)]
    var orientation = 0
    for operation in operations {
        switch operation {
        case .rotateR:
            orientation = (orientation + 1) % orientations.count
        case .rotateL:
            orientation -= 1
            if orientation < 0 { orientation = orientations.count - 1 }
        case .go(var steps):
            var lastValidRow = row
            var lastValidCol = col
            while steps > 0 {
                var nextRow = (row + orientations[orientation].row)
                if nextRow == map.count { nextRow = 0 } else if nextRow == -1 { nextRow = map.count - 1 }
                var nextCol = col + orientations[orientation].col
                if nextCol == mapWidth { nextCol = 0 } else if nextCol == -1 { nextCol = mapWidth - 1 }
                guard steps >= map[nextRow][nextCol] else { break }
                row = nextRow
                col = nextCol
                if map[row][col] == 1 {
                    lastValidRow = row
                    lastValidCol = col
                }
                steps -= map[nextRow][nextCol]
            }
            row = lastValidRow
            col = lastValidCol
        }
    }
    return 1000 * (row + 1) + 4 * (col + 1) + orientation
}

func solve2() -> Int {
    var col = map[0].firstIndex(of: 1)!
    var row = 0
    let orientations = [(row: 0, col: 1), (row: 1, col: 0), (row: 0, col: -1), (row: -1, col: 0)]
    var orientation = 0
    for operation in operations {
        switch operation {
        case .rotateR:
            orientation = (orientation + 1) % orientations.count
        case .rotateL:
            orientation -= 1
            if orientation < 0 { orientation = orientations.count - 1 }
        case .go(var steps):
            while steps > 0 {
                let lastValidOrientation = orientation
                var nextRow = (row + orientations[orientation].row)
                var nextCol = col + orientations[orientation].col
                if nextCol == mapWidth { // 1 -> 4
                    nextRow = 149 - nextRow
                    nextCol = 99
                    orientation = 2
                } else if nextRow == map.count { // 6 -> 1
                    nextRow = 0
                    nextCol += 100
                } else if nextRow < 0 {
                    if nextCol >= 100 { // 1 -> 6
                        nextCol -= 100
                        nextRow = map.count - 1
                    } else if (50...99).contains(nextCol) { // 2 -> 6
                        nextRow = 100 + nextCol
                        nextCol = 0
                        orientation = 0
                    } else {
                        print("\(nextCol) \(nextRow)")
                        fatalError()
                    }
                } else if nextCol < 0 {
                    if (150...199).contains(nextRow) { // 6 -> 2
                        nextCol = nextRow - 100
                        nextRow = 0
                        orientation = 1
                    } else if (100...149).contains(nextRow) { // 5 -> 2
                        nextRow = 49 - (nextRow - 100)
                        nextCol = 50
                        orientation = 0
                    } else {
                        print("\(nextCol) \(nextRow)")
                        fatalError()
                    }
                } else if map[nextRow][nextCol] == 0 {
                    if (100...149).contains(col) { // 1 -> 3
                        nextRow = nextCol - 50
                        nextCol = 99
                        orientation = 2
                    } else if (50...99).contains(row) && (50...99).contains(col) {
                        if nextCol == 100 { // 3 -> 1
                            nextCol = nextRow + 50
                            nextRow = 49
                            orientation = 3
                        } else if nextCol < 50 { // 3 -> 5
                            nextCol = nextRow - 50
                            nextRow = 100
                            orientation = 1
                        } else {
                            print("\(nextCol) \(nextRow)")
                            fatalError()
                        }
                    } else if (0...49).contains(col) && (100...149).contains(row) { // 5 -> 3
                        nextRow = nextCol + 50
                        nextCol = 50
                        orientation = 0
                    } else if (0...49).contains(row) && (50...99).contains(col) { // 2 -> 5
                        nextRow = 149 - nextRow
                        nextCol = 0
                        orientation = 0
                    } else if (50...99).contains(col) && (100...149).contains(row) {
                        orientation = 2
                        if nextCol == 100 { // 4 -> 1
                            nextRow = 49 - (nextRow - 100)
                            nextCol = 149
                        } else if nextRow == 150 { // 4 -> 6
                            nextRow = nextCol + 100
                            nextCol = 49
                        } else {
                            print("\(nextCol) \(nextRow)")
                            fatalError()
                        }
                    } else if (150...199).contains(nextRow) { // 6 -> 4
                        nextCol = nextRow - 100
                        nextRow = 149
                        orientation = 3
                    }
                }
                if map[nextRow][nextCol] == 0 {
                    print("\(row) \(col)")
                    fatalError()
                }
                guard map[nextRow][nextCol] == 1 else {
                    orientation = lastValidOrientation
                    break
                }
                row = nextRow
                col = nextCol
                steps -= 1
            }
        }
    }
    return 1000 * (row + 1) + 4 * (col + 1) + orientation
}

let startTime = CFAbsoluteTimeGetCurrent()

//print(solve1())
print(solve2())

let diff = CFAbsoluteTimeGetCurrent() - startTime
print("\(#function) Took \(diff) seconds")
