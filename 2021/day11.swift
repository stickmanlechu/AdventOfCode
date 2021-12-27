import Foundation

final class Octopus {
    var value: Int
    var stepProcessed: Int = 0
    
    init(_ value: Int) {
        self.value = value
    }
}

func neighboursOfOctopus(atRow row: Int, col: Int, among octopi: [[Octopus]]) -> [(Int, Int)] {
    [(row - 1, col - 1),
     (row - 1, col),
     (row - 1, col + 1),
     (row, col - 1),
     (row, col + 1),
     (row + 1, col - 1),
     (row + 1, col),
     (row + 1, col + 1)].filter {
        $0.0 >= 0 && $0.0 < octopi.count && $0.1 >= 0 && $0.1 < octopi.count
    }
}

func prettyPrint(_ octopi: [[Octopus]]) {
    for row in octopi {
        print(row.map(\.value).map(String.init).joined())
    }
    print("\n")
}

func simulate(_ octopi: [[Octopus]], maxSteps: Int) -> Int {
    (1...maxSteps).reduce(0) { partialResult, step in
        partialResult + octopi.indices.reduce(0) { partialResult, row in
            partialResult + octopi[row].indices.reduce(0) { partialResult, col in
                partialResult + flashes(octopi, step: step, row: row, col: col, cascade: false)
            }
        }
    }
}

func flashes(_ octopi: [[Octopus]], step: Int, row: Int, col: Int, cascade: Bool) -> Int {
    let octopus = octopi[row][col]
    guard octopus.stepProcessed < step || octopus.value > 0 else { return 0 }
    if octopus.stepProcessed < step {
        octopus.stepProcessed = step
        octopus.value += 1
    }
    if cascade {
        octopus.value += 1
    }
    guard octopus.value > 9 else { return 0 }
    octopus.value = 0
    return 1 + neighboursOfOctopus(atRow: row, col: col, among: octopi).map {
        flashes(octopi, step: step, row: $0.0, col: $0.1, cascade: true)
    }.reduce(0, +)
}

extension Array where Element == Array<Octopus> {
    var allFlashed: Bool {
        for row in self {
            guard row.first(where: { $0.value != 0 }) == nil else { return false }
        }
        return true
    }
}

func firstCommonFlash(among octopi: [[Octopus]]) -> Int {
    var step = 0
    repeat {
        step += 1
        octopi.indices.forEach { row in
            octopi.indices.forEach { col in
                _ = flashes(octopi, step: step, row: row, col: col, cascade: false)
            }
        }
    } while !octopi.allFlashed
    return step
}

let input = (try! String(contentsOf: URL(fileURLWithPath: "input/day11.txt"), encoding: .utf8)).trimmingCharacters(in: .whitespacesAndNewlines)

let octopi: [[Octopus]] = input
    .split(separator: "\n")
    .map(String.init)
    .map { row in row.map { Octopus(Int(String($0))!) } }

let start = CFAbsoluteTimeGetCurrent()

print(simulate(octopi, maxSteps: 100))
//print(firstCommonFlash(among: octopi))

let diff = CFAbsoluteTimeGetCurrent() - start
print("\(#function) Took \(diff) seconds")
