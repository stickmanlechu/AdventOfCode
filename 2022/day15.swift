import Foundation

let input = try! String(contentsOf: URL(fileURLWithPath: "input/day15.txt"), encoding: .utf8)

struct Point: Hashable, Equatable {
    let x: Int
    let y: Int
    
    static func from(string: String) -> Self {
        let nums = string.replacingOccurrences(of: "x=", with: "").replacingOccurrences(of: " y=", with: "").components(separatedBy: ",").compactMap(Int.init)
        return .init(x: nums[0], y: nums[1])
    }
    
    var string: String {
        "\(x),\(y)"
    }
    
    func distance(to another: Point) -> Int {
        abs(another.x - x) + abs(another.y - y)
    }
}

extension ClosedRange where Element == Int {
    func contains(_ another: Self) -> Bool {
        contains(another.lowerBound) && contains(another.upperBound)
    }
    
    func intersects(_ another: Self) -> Bool {
        contains(another.lowerBound) || contains(another.upperBound) || another.contains(self)
    }
    
    func remove(_ another: Self) -> [Self] {
        guard self.intersects(another) else { return [self] }
        guard !another.contains(self) else { return [] }
        if another.lowerBound <= lowerBound {
            return [(another.upperBound + 1)...upperBound]
        }
        if another.upperBound >= upperBound {
            return [lowerBound...(another.lowerBound - 1)]
        }
        return [
            lowerBound...(another.lowerBound - 1),
            (another.upperBound + 1)...upperBound
        ]
    }
}

let pairs = input.components(separatedBy: "\n")
    .filter({ !$0.isEmpty })
    .map { $0.replacingOccurrences(of: "Sensor at ", with: "") }
    .map { $0.replacingOccurrences(of: " closest beacon is at ", with: "") }
    .map { $0.components(separatedBy: ":").map(Point.from(string:)) }

let pointAndMaxDistance = pairs
    .map { ($0[0], $0[0].distance(to: $0[1])) }

func solve1(theY: Int) -> Int {
    var xValues = Set<Int>()
    for pointAndDistance in pointAndMaxDistance {
        let xDiffMax = pointAndDistance.1 - abs(pointAndDistance.0.y - theY)
        let x1 = xDiffMax + pointAndDistance.0.x
        let x2 = -xDiffMax + pointAndDistance.0.x
        let lowerBound = min(x1, x2) + 1
        let upperBound = max(x1, x2)
        guard lowerBound <= upperBound else { continue }
        for x in lowerBound...upperBound {
            xValues.insert(x)
        }
    }
    return xValues.count
}

func solve2(maxX: Int, maxY: Int) -> Int {
    for y in 0...maxY {
        var ranges = [0...maxX]
        for pointAndDistance in pointAndMaxDistance {
            let xDiffMax = pointAndDistance.1 - abs(pointAndDistance.0.y - y)
            guard xDiffMax > 0 else { continue }
            let x1 = xDiffMax + pointAndDistance.0.x
            let x2 = -xDiffMax + pointAndDistance.0.x
            let lowerBound = min(x1, x2)
            let upperBound = max(x1, x2)
            guard lowerBound <= upperBound else { continue }
            let range = lowerBound...upperBound
            ranges = ranges.flatMap { $0.remove(range) }
            guard !ranges.isEmpty else { break }
        }
        guard !ranges.isEmpty else { continue }
        return ranges[0].lowerBound * 4000000 + y
    }
    return -1
}

let startTime = CFAbsoluteTimeGetCurrent()

//print(solve1(theY: 2000000))
print(solve2(maxX: 4000000, maxY: 4000000))

let diff = CFAbsoluteTimeGetCurrent() - startTime
print("\(#function) Took \(diff) seconds")
