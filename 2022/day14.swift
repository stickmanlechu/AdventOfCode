import Foundation

let input = try! String(contentsOf: URL(fileURLWithPath: "input/day14.txt"), encoding: .utf8)

struct Point: Hashable, Equatable {
    let x: Int
    let y: Int
    
    static func from(string: String) -> Self {
        let nums = string.components(separatedBy: ",").compactMap(Int.init)
        return .init(x: nums[0], y: nums[1])
    }
    
    var string: String {
        "\(x),\(y)"
    }
    
    var possibleMoves: [Point] {
        [.init(x: x, y: y + 1), .init(x: x - 1, y: y + 1), .init(x: x + 1, y: y + 1)]
    }
    
    func points(to anotherPoint: Point) -> Set<Point> {
        var intermediate = Set<Point>()
        if x == anotherPoint.x { // vertical
            for newY in min(y, anotherPoint.y)...max(y, anotherPoint.y) {
                intermediate.insert(Point(x: x, y: newY))
            }
        } else { // horizontal
            for newX in min(x, anotherPoint.x)...max(x, anotherPoint.x) {
                intermediate.insert(Point(x: newX, y: y))
            }
        }
        return intermediate
    }
}

var cavern: Set<Point> = []
for line in input.components(separatedBy: "\n").filter({ !$0.isEmpty }) {
    let points = line.components(separatedBy: " -> ").map(Point.from(string:))
    for index in points.indices.dropLast() {
        cavern.formUnion(points[index].points(to: points[index + 1]))
    }
}
let maxY = cavern.map(\.y).max()!

func solve1() -> Int {
    var stabilizedGrains = 0
    while true {
        var point = Point(x: 500, y: 0)
        while true {
            guard let newPoint = point.possibleMoves.first(where: { !cavern.contains($0) }) else {
                cavern.insert(point)
                stabilizedGrains += 1
                break
            }
            guard newPoint.y <= maxY else {
                return stabilizedGrains
            }
            point = newPoint
        }
    }
}

func solve2() -> Int {
    let floor = maxY + 1
    var grains = 0
    while true {
        var point = Point(x: 500, y: 0)
        grains += 1
        while true {
            guard let newPoint = point.possibleMoves.first(where: { !cavern.contains($0) }) else {
                cavern.insert(point)
                if point.x == 500 && point.y == 0 { return grains }
                break
            }
            guard newPoint.y < floor else {
                cavern.insert(newPoint)
                break
            }
            point = newPoint
        }
    }
}

let startTime = CFAbsoluteTimeGetCurrent()

print(solve2())

let diff = CFAbsoluteTimeGetCurrent() - startTime
print("\(#function) Took \(diff) seconds")
