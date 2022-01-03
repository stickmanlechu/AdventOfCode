import Foundation

typealias Point = [Int]

extension Point {
    var neighbors: Set<Point> {
        var results: [[Int]] = [[]]
        for num in self {
            var newResults = [[Int]]()
            results.forEach {
                for i in (num - 1)...(num + 1) {
                    newResults.append($0 + [i])
                }
            }
            results = newResults
        }
        var neighbors = Set(results)
        neighbors.remove(self)
        return neighbors
    }
}

func solve(_ input: String, dimensions: Int) -> Int {
    var space = input
        .trimmingCharacters(in: .whitespacesAndNewlines)
        .components(separatedBy: "\n")
        .enumerated()
        .reduce(into: Set<Point>()) { partialResult, line in
            line.element.enumerated().forEach { char in
                guard char.element == "#" else { return }
                var cube = [line.offset, char.offset]
                while cube.count < dimensions {
                    cube.append(0)
                }
                partialResult.insert(cube)
            }
        }
    for _ in 1...6 {
        var newSpace = Set<Point>()
        var activeCounts = [Point: Int]()
        for point in space {
            point.neighbors.forEach { activeCounts[$0, default: 0] += 1 }
        }
        for point in activeCounts.keys {
            if activeCounts[point, default: 0] == 3 {
                newSpace.insert(point)
                continue
            }
            if space.contains(point) && activeCounts[point, default: 0] == 2 {
                newSpace.insert(point)
            }
        }
        space = newSpace
    }
    return space.count
}

let input = try! String(contentsOf: URL(fileURLWithPath: "input/day17.txt"), encoding: .utf8)

let start = CFAbsoluteTimeGetCurrent()

print(solve(input, dimensions: 4))

let diff = CFAbsoluteTimeGetCurrent() - start
print("\(#function) Took \(diff) seconds")


