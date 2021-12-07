// https://adventofcode.com/2021/day/5

import Foundation

let input = try! String(contentsOf: URL(fileURLWithPath: "input/day5.txt"), encoding: .utf8)

struct Point: Hashable, CustomStringConvertible {
    let x: Int
    let y: Int
    
    init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
    
    init(_ str: String) {
        let comps = str.split(separator: ",")
            .map(String.init)
            .map { Int($0)! }
        self.x = comps[0]
        self.y = comps[1]
    }
    
    var description: String {
        "(\(x), \(y))"
    }
}

final class Line {
    let p1: Point
    let p2: Point
    
    init(_ str: String) {
        let points = str.replacingOccurrences(of: " -> ", with: ":")
            .split(separator: ":")
            .map(String.init)
            .map(Point.init)
        self.p1 = points[0]
        self.p2 = points[1]
    }
    
    var isHorizontal: Bool {
        p1.y == p2.y
    }
    
    var isVertical: Bool {
        p1.x == p2.x
    }
    
    lazy var a: Int = Int(truncating: NSDecimalNumber(decimal: Decimal(p2.y - p1.y)/Decimal(p2.x - p1.x)))
    
    lazy var b: Int = Int(truncating: NSDecimalNumber(decimal: Decimal(p2.x * p1.y - p1.x * p2.y)/Decimal(p2.x - p1.x)))
    
    lazy var containedPoints: [Point] = {
        if isVertical {
            let lowerY = min(p1.y, p2.y)
            let upperY = max(p1.y, p2.y)
            return (lowerY...upperY).map { Point(x: p1.x, y: $0) }
        }
        let lowerX = min(p1.x, p2.x)
        let upperX = max(p1.x, p2.x)
        let points = (lowerX...upperX).map { Point(x: $0, y: (a * $0 + b)) }
        return points
    }()
}

let lines = input
    .split(separator: "\n")
    .map(String.init)
    .map(Line.init)

func countOverlapping(from lines: [Line], countDiagonal: Bool) -> Int {
    let filtered = lines.filter({
        countDiagonal ? true : $0.isVertical || $0.isHorizontal
    })
    var added: Set<Point> = []
    var points: Set<Point> = []
    var totalOverlapping: Int = 0
    filtered.forEach { line in
        for point in line.containedPoints {
            guard points.contains(point) else {
                points.insert(point)
                continue
            }
            guard !added.contains(point) else { continue }
            added.insert(point)
            totalOverlapping += 1
        }
    }
    return totalOverlapping
}

let start = CFAbsoluteTimeGetCurrent()

print(countOverlapping(from: lines, countDiagonal: true))

let diff = CFAbsoluteTimeGetCurrent() - start
print("\(#function) Took \(diff) seconds")
