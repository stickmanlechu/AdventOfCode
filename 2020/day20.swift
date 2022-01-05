import Foundation

typealias ParsedTile = [[Bool]]

extension ParsedTile {
    func rotated() -> ParsedTile {
        indices.map { idx in
            indices.reversed().map { self[$0][idx] }
        }
    }
    
    func allRotationsAndFlips() -> [ParsedTile] {
        let rot90 = rotated()
        let rot180 = rot90.rotated()
        let rot270 = rot180.rotated()
        let flip = Array(self.reversed())
        let flip90 = flip.rotated()
        let flip180 = flip90.rotated()
        let flip270 = flip180.rotated()
        return [self, rot90, rot180, rot270, flip, flip90, flip180, flip270]
    }
    
    func checkLeft(_ another: ParsedTile) -> Bool {
        map { $0.first! } == another.map { $0.last! }
    }
    
    func checkUp(_ another: ParsedTile) -> Bool {
        first! == another.last!
    }
    
    func removingBorder() -> ParsedTile {
        dropFirst()
            .dropLast()
            .map { $0.dropFirst().dropLast() }
    }
    
    mutating func merge(_ another: ParsedTile) {
        indices.forEach { self[$0].append(contentsOf: another[$0]) }
    }
    
    func asString() -> String {
        map { row in row.map { $0 ? "#" : "." }.joined() }.joined(separator: "\n")
    }
}

let monsterPattern = ["..................#.", "#....##....##....###", ".#..#..#..#..#..#..."]

extension String {
    func numberOfMonsters(maxWidth: Int) -> Int {
        let rowWidth = monsterPattern[0].count
        return (0..<(maxWidth - rowWidth))
            .reduce(0) { partialResult, index in
                let pattern = monsterPattern.map {
                    String(repeating: ".", count: index) + $0 + String(repeating: ".", count: maxWidth - rowWidth - index)
                }.joined(separator: "\n")
                let regexp = try! NSRegularExpression(pattern: pattern, options: [])
                return partialResult + regexp.numberOfMatches(in: self, options: [], range: NSRange(location: 0, length: count))
            }
    }
}

func parse(tile: String) -> (Int, [ParsedTile]) {
    let lines = tile.components(separatedBy: "\n")
    let tileNo = Int(lines[0].replacingOccurrences(of: "(Tile )|:", with: "", options: .regularExpression))!
    return (tileNo, lines.dropFirst().map { line in line.map { $0 == "#" } }.allRotationsAndFlips())
}

func solve(_ tiles: [(Int, [ParsedTile])]) -> ([ParsedTile], [Int], Int) {
    let tilesInRow = Int(sqrt(Double(tiles.count)))
    for tileIndex in tiles {
        for tile in tileIndex.1 {
            var board = [tile]
            var tileIndexes = [tileIndex.0]
            guard solve(&board, tileIndexes: &tileIndexes, tilesInRow: tilesInRow, allTiles: tiles) else { continue }
            return (board, tileIndexes, tilesInRow)
        }
    }
    fatalError()
}

func solve(_ board: inout [ParsedTile], tileIndexes: inout [Int], tilesInRow: Int, allTiles: [(Int, [ParsedTile])]) -> Bool {
    guard tileIndexes.count != tilesInRow * tilesInRow else { return true }
    let tilesLeft = allTiles.filter { !tileIndexes.contains($0.0) }
    var candidates = [(Int, ParsedTile)]()
    let checkLeft = board.count % tilesInRow != 0
    let checkUp = board.count / tilesInRow != 0
    for pair in tilesLeft {
        for tileVariant in pair.1 {
            if checkLeft && !tileVariant.checkLeft(board.last!) { continue }
            if checkUp && !tileVariant.checkUp(board[board.count - tilesInRow]) { continue }
            candidates.append((pair.0, tileVariant))
        }
    }
    guard !candidates.isEmpty else {
        return false
    }
    for candidate in candidates {
        board.append(candidate.1)
        tileIndexes.append(candidate.0)
        guard !solve(&board, tileIndexes: &tileIndexes, tilesInRow: tilesInRow, allTiles: allTiles) else {
            return true
        }
        _ = board.removeLast()
        _ = tileIndexes.removeLast()
    }
    return false
}

func solve1(_ tiles: [(Int, [ParsedTile])]) -> Int {
    let (_, tileIndexes, tilesInRow) = solve(tiles)
    return tileIndexes[0] * tileIndexes[tilesInRow - 1] * tileIndexes[tileIndexes.count - tilesInRow] * tileIndexes[tileIndexes.count - 1]
}

func solve2(_ tiles: [(Int, [ParsedTile])]) -> Int {
    let (board, _, tilesInRow) = solve(tiles)
    let boardWithoutBorders = board.map { $0.removingBorder() }
    let image = stride(from: 0, to: boardWithoutBorders.count, by: tilesInRow)
        .map{ index in
            (index..<(index + tilesInRow)).dropFirst().reduce(into: boardWithoutBorders[index]) { $0.merge(boardWithoutBorders[$1]) }
        }
        .flatMap {
            $0
        }
    for variant in Array(image).allRotationsAndFlips() {
        let stringImage = variant.asString()
        let count = stringImage.numberOfMonsters(maxWidth: variant.count)
        guard count > 0 else {
            continue
        }
        return stringImage.filter { $0 == "#" }.count - count * monsterPattern.joined().filter { $0 == "#" }.count
    }
    return 0
}

let input = try! String(contentsOf: URL(fileURLWithPath: "input/day20.txt"), encoding: .utf8)
let tiles = input
    .trimmingCharacters(in: .whitespacesAndNewlines)
    .components(separatedBy: "\n\n")
    .map(parse(tile:))

let start = CFAbsoluteTimeGetCurrent()

//print(solve1(tiles))
print(solve2(tiles))

let diff = CFAbsoluteTimeGetCurrent() - start
print("\(#function) Took \(diff) seconds")
