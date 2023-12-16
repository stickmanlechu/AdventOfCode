import Foundation

let input = try! String(contentsOf: URL(fileURLWithPath: "input/day16.txt"), encoding: .utf8).trimmingCharacters(in: .whitespacesAndNewlines)

struct Point2D: Hashable {
    let row: Int
    let col: Int
}

struct Beam: Hashable {
    var position: Point2D
    let direction: Point2D
    
    mutating func move() {
        position = .init(row: position.row + direction.row, col: position.col + direction.col)
    }
    
    func beams(with mirror: Character) -> [Beam] {
        switch mirror {
        case "/":
            return [.init(position: position, direction: .init(row: -direction.col, col: -direction.row))]
        case "\\":
            return [.init(position: position, direction: .init(row: direction.col, col: direction.row))]
        case "|":
            guard direction.row == 0 else { return [self] }
            return [.init(position: position, direction: .init(row: 1, col: 0)),
                    .init(position: position, direction: .init(row: -1, col: 0))]
        case "-":
            guard direction.col == 0 else { return [self] }
            return [.init(position: position, direction: .init(row: 0, col: 1)),
                    .init(position: position, direction: .init(row: 0, col: -1))]
        case ".": return [self]
        default: fatalError()
        }
    }
}

func solve(map: [[Character]], initialBeam: Beam) -> Int {
    let maxRow = map.count - 1
    let maxCol = map[0].count - 1
    var cycled = Set<Beam>()
    var warmed = Set<Point2D>()
    var lightBeams = [initialBeam]
    while !lightBeams.isEmpty {
        var beam = lightBeams.removeFirst()
        beam.move()
        guard !cycled.contains(beam) else { continue }
        cycled.insert(beam)
        guard beam.position.row >= 0 && beam.position.row <= maxRow && beam.position.col >= 0 && beam.position.col <= maxCol else {continue }
        warmed.insert(beam.position)
        lightBeams.append(contentsOf: beam.beams(with: map[beam.position.row][beam.position.col]))
    }
    return warmed.count
}

func solve1(map: [[Character]]) -> Int {
    solve(map: map, initialBeam: Beam(position: .init(row: 0, col: -1), direction: .init(row: 0, col: 1)))
}

func solve2(map: [[Character]]) -> Int {
    var maxValue = 0
    let maxRow = map.count
    let maxCol = map[0].count
    for row in map.indices {
        var initialBeam = Beam(position: .init(row: row, col: -1), direction: .init(row: 0, col: 1))
        maxValue = max(solve(map: map, initialBeam: initialBeam), maxValue)
        initialBeam = Beam(position: .init(row: row, col: maxCol), direction: .init(row: 0, col: -1))
        maxValue = max(solve(map: map, initialBeam: initialBeam), maxValue)
    }
    for col in map[0].indices {
        var initialBeam = Beam(position: .init(row: -1, col: col), direction: .init(row: 1, col: 0))
        maxValue = max(solve(map: map, initialBeam: initialBeam), maxValue)
        initialBeam = Beam(position: .init(row: maxRow, col: col), direction: .init(row: -1, col: 0))
        maxValue = max(solve(map: map, initialBeam: initialBeam), maxValue)
    }
    return maxValue
}

let start = CFAbsoluteTimeGetCurrent()

let map = input.components(separatedBy: .newlines).filter { !$0.isEmpty }
    .map { $0.map { $0 } }

print(solve1(map: map))
print(solve2(map: map))

let diff = CFAbsoluteTimeGetCurrent() - start
print("\(#function) Took \(diff) seconds")
