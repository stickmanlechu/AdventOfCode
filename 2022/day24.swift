import Foundation

let input = try! String(contentsOf: URL(fileURLWithPath: "input/day24.txt"), encoding: .utf8)

struct Point: Hashable {
    var row: Int
    var col: Int
    
    var possibleMoves: [Point] {
        [
            .init(row: row - 1, col: col),
            .init(row: row + 1, col: col),
            .init(row: row, col: col - 1),
            .init(row: row, col: col + 1),
            self
        ]
    }
}

enum Wind: String, Hashable {
    case right = ">"
    case left = "<"
    case up = "^"
    case down = "v"
}

let lines = input
    .components(separatedBy: "\n")
    .filter({ !$0.isEmpty })

let winds = lines
    .enumerated()
    .reduce(into: [Point: Wind]()) { map, line in
        for maybeWind in Array(line.element.dropFirst()).map(String.init).enumerated() {
            guard let wind = Wind(rawValue: maybeWind.element) else { continue }
            map[.init(row: line.offset, col: maybeWind.offset)] = wind
        }
    }

let width = lines[0].count - 2
func occupied(at minute: Int) -> Set<Point> {
    var occupied = Set<Point>()
    for windPoint in winds {
        var position = windPoint.key
        switch windPoint.value {
        case .up:
            let newRow = (position.row - minute) % (lines.count - 2)
            if newRow > 0 { position.row = newRow }
            else { position.row = newRow <= 0 ? (lines.count - 2 + newRow) : newRow }
        case .down:
            let newRow = (position.row + minute) % (lines.count - 2)
            position.row = newRow == 0 ? lines.count - 2 : newRow
        case .right:
            position.col = (position.col + minute) % width
        case .left:
            let newCol = (position.col - minute) % width
            if newCol > 0 { position.col = newCol }
            else { position.col = newCol == 0 ? 0 : (width + newCol) }
        }
        occupied.insert(position)
    }
    return occupied
}

func solve(start: Point, end: Point, minutes: Int) -> Int {
    var possibleMovesPerMinute: [Set<Point>] = [[start]]
    var minute = minutes
    while !possibleMovesPerMinute.last!.contains(end) {
        minute += 1
        let occupied = occupied(at: minute)
        var newPossibleMoves = Set<Point>()
        for position in possibleMovesPerMinute[minute - minutes - 1] {
            for newPossibleMove in position.possibleMoves {
                if newPossibleMove == end { return minute }
                guard !occupied.contains(newPossibleMove) else { continue }
                guard (newPossibleMove.row > 0 || newPossibleMove == start), newPossibleMove.col >= 0 else { continue }
                guard (newPossibleMove.row < lines.count - 1 || newPossibleMove == start) else { continue }
                guard newPossibleMove.col < width else { continue }
                newPossibleMoves.insert(newPossibleMove)
            }
        }
        possibleMovesPerMinute.append(newPossibleMoves)
    }
    return minute
}

func solve1() -> Int {
    return solve(start: .init(row: 0, col: 0), end: Point(row: lines.count - 1, col: width - 1), minutes: 0)
}

func solve2() -> Int {
    let start = Point(row: 0, col: 0)
    let end = Point(row: lines.count - 1, col: width - 1)
    let startEnd = solve(start: start, end: end, minutes: 0)
    let endStart = solve(start: end, end: start, minutes: startEnd)
    return solve(start: start, end: end, minutes: endStart)
}

let startTime = CFAbsoluteTimeGetCurrent()

//print(solve1())
print(solve2())

let diff = CFAbsoluteTimeGetCurrent() - startTime
print("\(#function) Took \(diff) seconds")
