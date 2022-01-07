import Foundation

enum Direction: String, CaseIterable, Hashable {
    case se, sw, nw, ne, e, w
}

struct Point: Hashable {
    let x: Int
    let y: Int
    
    var adjacent: [Point] {
        return Direction.allCases.map { byMoving(in: $0) }
    }
    
    func byMoving(in direction: Direction) -> Point {
        switch direction {
        case .se:
            return Point(x: x + 1, y: y - 1)
        case .sw:
            return Point(x: x - 1, y: y - 1)
        case .nw:
            return Point(x: x - 1, y: y + 1)
        case .ne:
            return Point(x: x + 1, y: y + 1)
        case .e:
            return Point(x: x + 2, y: y)
        case .w:
            return Point(x: x - 2, y: y)
        }
    }
}

func parse(_ line: String) -> [Direction] {
    let allPossible = Direction.allCases
    var line = line
    var directions = [Direction]()
    while !line.isEmpty {
        let dir = allPossible.first(where: { line.hasPrefix($0.rawValue) })!
        directions.append(dir)
        line.removeFirst(dir.rawValue.count)
    }
    return directions
}

func flippedTiles(_ input: String) -> [Point: Bool] {
    let instructionSets = input
        .trimmingCharacters(in: .whitespacesAndNewlines)
        .components(separatedBy: "\n")
        .map(parse)
    
    var tiles = [Point(x: 0, y: 0): false]
    for instructions in instructionSets {
        var point = Point(x: 0, y: 0)
        for direction in instructions {
            point = point.byMoving(in: direction)
        }
        tiles[point] = !tiles[point, default: false]
    }
    return tiles
}

func flip(_ floor: inout [Point: Bool]) {
    var toCheckOutside: Set<Point> = .init()
    var newFloor = [Point: Bool]()
    for point in floor.keys {
        toCheckOutside.formUnion(point.adjacent)
        flip(point, floor, &newFloor)
    }
    for point in toCheckOutside {
        flip(point, floor, &newFloor)
    }
    floor = newFloor
}

func flip(_ point: Point, _ floor: [Point: Bool], _ newFloor: inout [Point: Bool]) {
    let neighbors = point.adjacent
    let blackNeighbors = neighbors.filter { floor[$0, default: false] }.count
    if floor[point, default: false] && (blackNeighbors == 1 || blackNeighbors == 2) {
        newFloor[point] = true
        return
    }
    if !floor[point, default: false] && blackNeighbors == 2 {
        newFloor[point] = true
    }
}

func solve1(_ input: String) -> Int {
    return flippedTiles(input).filter { $0.value }.count
}

func solve2(_ input: String) -> Int {
    var floor = flippedTiles(input)
    for _ in 1...100 {
        flip(&floor)
    }
    return floor.filter { $0.value }.count
}

let input = try! String(contentsOf: URL(fileURLWithPath: "input/day24.txt"), encoding: .utf8)
let start = CFAbsoluteTimeGetCurrent()

print(solve2(input))

let diff = CFAbsoluteTimeGetCurrent() - start
print("\(#function) Took \(diff) seconds")
