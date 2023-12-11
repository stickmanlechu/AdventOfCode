import Foundation

let input = try! String(contentsOf: URL(fileURLWithPath: "input/day11.txt"), encoding: .utf8)

struct Galaxy: Hashable {
    var row: Int
    var col: Int
    
    func distanceTo(another galaxy: Galaxy) -> Int {
        abs(galaxy.row - row) + abs(galaxy.col - col)
    }
}

func solve(_ expansionSize: Int) -> Int {
    var galaxies = [Galaxy]()
    let universeMap = input.components(separatedBy: .newlines)
        .filter { !$0.isEmpty }
        .map { $0.map(String.init) }
    for (row, line) in universeMap.enumerated() {
        for (col, sign) in line.enumerated() {
            guard sign == "#" else { continue }
            galaxies.append(.init(row: row, col: col))
        }
    }
    let rowNumbers = Set(universeMap.indices)
    let colNumbers = Set(universeMap[0].indices)
    let galaxyRows = Set(galaxies.map(\.row))
    let galaxyCols = Set(galaxies.map(\.col))
    
    var translations = galaxies.reduce(into: [Galaxy: Galaxy]()) { $0[$1] = $1 }
    
    for emptyCol in colNumbers.subtracting(galaxyCols) {
        for galaxy in galaxies where galaxy.col > emptyCol {
            translations[galaxy]!.col += expansionSize
        }
    }
    for emptyRow in rowNumbers.subtracting(galaxyRows) {
        for galaxy in galaxies where galaxy.row > emptyRow {
            translations[galaxy]!.row += expansionSize
        }
    }
    var totalDistance = 0
    for i in galaxies.indices.dropLast() {
        for j in (i + 1)..<galaxies.endIndex {
            let calculatedDistance = translations[galaxies[i]]!.distanceTo(another: translations[galaxies[j]]!)
            totalDistance += calculatedDistance
        }
    }
    return totalDistance
}

let start = CFAbsoluteTimeGetCurrent()

print(solve(1))
print(solve(999999))

let diff = CFAbsoluteTimeGetCurrent() - start
print("\(#function) Took \(diff) seconds")
