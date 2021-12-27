import Foundation

extension Character {
    static let r: Character = ">"
    static let d: Character = "v"
    static let empty: Character = "."
}

func next(_ seafloor: inout [[Character]]) -> Bool {
    var newSeaflor = seafloor
    let rows = seafloor.count
    let cols = seafloor[0].count
    var changed = false
    for row in seafloor.indices {
        for col in seafloor[row].indices {
            guard seafloor[row][col] == .r else { continue }
            guard seafloor[row][(col + 1) % cols] == .empty else { continue }
            changed = true
            newSeaflor[row][col] = .empty
            newSeaflor[row][(col + 1) % cols] = .r
        }
    }
    seafloor = newSeaflor
    for row in seafloor.indices {
        for col in seafloor[row].indices {
            guard seafloor[row][col] == .d else { continue }
            guard seafloor[(row + 1) % rows][col] == .empty else { continue }
            changed = true
            newSeaflor[row][col] = .empty
            newSeaflor[(row + 1) % rows][col] = .d
        }
    }
    seafloor = newSeaflor
    return changed
}

func solve(cucumbers: [[Character]]) -> Int {
    var count = 1
    var seafloor = cucumbers
    while next(&seafloor) {
        count += 1
    }
    return count
}

let input = (try! String(contentsOf: URL(fileURLWithPath: "input/day25.txt"), encoding: .utf8)).trimmingCharacters(in: .whitespacesAndNewlines)
let cucumbers: [[Character]] = input
    .split(separator: "\n")
    .map { Array($0) }

let start = CFAbsoluteTimeGetCurrent()

print(solve(cucumbers: cucumbers))

let diff = CFAbsoluteTimeGetCurrent() - start
print("\(#function) Took \(diff) seconds")
