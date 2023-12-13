import Foundation

let input = try! String(contentsOf: URL(fileURLWithPath: "input/day13.txt"), encoding: .utf8)

struct Mirror {
    let isVertical: Bool
    let middle: Int
    let start: Int
    let end: Int
    var size: Int {
        end - start
    }
}

func score(for map: [[Character]], smudgesExpected: Int) -> Int {
    var possibleMirrors: [Mirror] = []
    for col1 in map[0].indices {
        for col2 in map[0].indices.reversed() {
            if let col = isMirrorVertical(col1: col1, col2: col2, map: map, smudgesExpected: smudgesExpected) {
                possibleMirrors.append(.init(isVertical: true, middle: col, start: col1, end: col2))
            }
        }
    }
    for row1 in map.indices {
        for row2 in map.indices.reversed() {
            if let row = isMirrorHorizontal(row1: row1, row2: row2, map: map, smudgesExpected: smudgesExpected) {
                possibleMirrors.append(.init(isVertical: false, middle: row, start: row1, end: row2))
            }
        }
    }
    possibleMirrors = possibleMirrors.filter { $0.start == 0 || ($0.end == map.endIndex - 1 && !$0.isVertical) || ($0.end == map[0].endIndex - 1 && $0.isVertical) }
    guard let mirror = possibleMirrors.max(by: { $0.size < $1.size }) else { return 0 }
    return mirror.isVertical ? mirror.middle : 100 * mirror.middle
}

func isMirrorHorizontal(row1: Int, row2: Int, map: [[Character]], smudgesExpected: Int) -> Int? {
    guard row1 < row2 else { return nil }
    var smudgesExpected = smudgesExpected
    for col in map[row1].indices {
        if map[row1][col] == map[row2][col] {
            continue
        }
        smudgesExpected -= 1
        guard smudgesExpected >= 0 else { return nil }
    }
    if row1 + 1 == row2 { return smudgesExpected == 0 ? row1 + 1 : nil }
    return isMirrorHorizontal(row1: row1 + 1, row2: row2 - 1, map: map, smudgesExpected: smudgesExpected)
}

func isMirrorVertical(col1: Int, col2: Int, map: [[Character]], smudgesExpected: Int) -> Int? {
    guard col1 < col2 else { return nil }
    var smudgesExpected = smudgesExpected
    for row in map.indices {
        if map[row][col1] == map[row][col2] {
            continue
        }
        smudgesExpected -= 1
        guard smudgesExpected >= 0 else { return nil }
    }
    if col1 + 1 == col2 { return smudgesExpected == 0 ? col1 + 1 : nil }
    return isMirrorVertical(col1: col1 + 1, col2: col2 - 1, map: map, smudgesExpected: smudgesExpected)
}

func solve1(map: [[Character]]) -> Int {
    score(for: map, smudgesExpected: 0)
}

func solve2(map: [[Character]]) -> Int {
    score(for: map, smudgesExpected: 1)
}

let start = CFAbsoluteTimeGetCurrent()

let maps = input.components(separatedBy: "\n\n")
    .map { singleInput in
        singleInput.components(separatedBy: .newlines)
            .filter { !$0.isEmpty }
            .map {
                $0.map { $0 }
            }
    }

print("part 1: \(maps.map(solve1).reduce(0, +))")
print("part 2: \(maps.map(solve2).reduce(0, +))")

let diff = CFAbsoluteTimeGetCurrent() - start
print("\(#function) Took \(diff) seconds")
