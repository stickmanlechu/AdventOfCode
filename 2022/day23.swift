import Foundation

let input = try! String(contentsOf: URL(fileURLWithPath: "input/day23.txt"), encoding: .utf8)

struct Point: Hashable {
    let x: Int
    let y: Int
    
    func adding(_ another: Point) -> Point {
        .init(x: x + another.x, y: y + another.y)
    }
    
    var neighbours: [Point] {
        [.init(x: x - 1, y: y - 1), .init(x: x - 1, y: y), .init(x: x - 1, y: y + 1),
         .init(x: x, y: y - 1), .init(x: x, y: y + 1),
         .init(x: x + 1, y: y - 1), .init(x: x + 1, y: y), .init(x: x + 1, y: y + 1)]
    }
}

let moves: [[Point]] = [
    [Point(x: -1, y: -1), Point(x: 0, y: -1), Point(x: 1, y: -1)],
    [Point(x: -1, y: 1), Point(x: 0, y: 1), Point(x: 1, y: 1)],
    [Point(x: -1, y: 1), Point(x: -1, y: 0), Point(x: -1, y: -1)],
    [Point(x: 1, y: 1), Point(x: 1, y: 0), Point(x: 1, y: -1)]
]

var elves = Set(input.components(separatedBy: "\n").filter({ !$0.isEmpty }).enumerated().flatMap { row in
    Array(row.element).enumerated().compactMap { $0.element == "#" ? Point(x: $0.offset, y: row.offset) : nil }
})

func printElves() {
    let xs = elves.map(\.x)
    let ys = elves.map(\.y)
    for y in ys.min()!...ys.max()! {
        for x in xs.min()!...xs.max()! {
            print(elves.contains(.init(x: x, y: y)) ? "#" : ".", terminator: "")
        }
        print()
    }
    print()
}

func solve(roundCap: Int) -> Int {
    var firstMove = 0
    var round = 0
    while round < roundCap {
        var nextMoves = [Point: [Point]]()
        var anyoneMoved = false
        for elf in elves {
            if elves.isDisjoint(with: elf.neighbours) {
                nextMoves[elf] = nextMoves[elf, default: []] + [elf]
                continue
            }
            anyoneMoved = true
            var blocked = true
            for i in 0..<4 {
                let move = moves[(firstMove + i) % 4]
                let movedPoints = move.map { elf.adding($0) }
                guard elves.isDisjoint(with: movedPoints) else { continue }
                nextMoves[movedPoints[1]] = nextMoves[movedPoints[1], default: []] + [elf]
                blocked = false
                break
            }
            if blocked {
                nextMoves[elf] = nextMoves[elf, default: []] + [elf]
            }
        }
        guard anyoneMoved else { break }
        elves.removeAll(keepingCapacity: true)
        for move in nextMoves {
            if move.value.count == 1 {
                elves.insert(move.key)
            } else {
                elves.formUnion(move.value)
            }
        }
        firstMove = (firstMove + 1) % 4
        round += 1
    }
    let xs = elves.map(\.x)
    let ys = elves.map(\.y)
    print(round + 1)
    return abs(xs.max()! - xs.min()! + 1) * abs(ys.max()! - ys.min()! + 1) - elves.count
}

let startTime = CFAbsoluteTimeGetCurrent()

//print(solve(roundCap: 10))
print(solve(roundCap: .max))

let diff = CFAbsoluteTimeGetCurrent() - startTime
print("\(#function) Took \(diff) seconds")
