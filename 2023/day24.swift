import Foundation

let input = try! String(contentsOf: URL(fileURLWithPath: "input/day24.txt"), encoding: .utf8).trimmingCharacters(in: .whitespacesAndNewlines)

struct Point: Hashable {
    let x, y, z: Double
    
    func moved(by vector: Point) -> Point {
        .init(x: x + vector.x, y: y + vector.y, z: z + vector.z)
    }
    
    func isFuture(_ another: Point, vector: Point) -> Bool {
        if another.x > x && vector.x < 0 { return false }
        if another.y > y && vector.y < 0 { return false }
        if another.x < x && vector.x > 0 { return false }
        if another.y < y && vector.y > 0 { return false }
        return true
    }
}

extension Array where Element == Point {
    func isFuture(_ another: Point) -> Bool {
        return self[0].isFuture(another, vector: self[1])
    }
}

struct Line: Hashable {
    let a: Double
    let b: Double
    
    static func with(_ pointAndVelocity: [Point]) -> Line {
        let point1 = pointAndVelocity[0]
        let point2 = pointAndVelocity[0].moved(by: pointAndVelocity[1])
        let a = (point2.y - point1.y) / (point2.x - point1.x)
        let b = point1.y - a * point1.x
        return .init(a: a, b: b)
    }
    
    func cross(with line: Line) -> Point? {
        guard a != line.a else { return nil }
        let x = (line.b - b) / (a - line.a)
        let y = a * x + b
        return .init(x: x, y: y, z: 0)
    }
}

let start = CFAbsoluteTimeGetCurrent()

var pointsAndVelocities = [[Point]]()
for line in input.components(separatedBy: .newlines).filter({ !$0.isEmpty }) {
    let comps = line
        .replacingOccurrences(of: " ", with: "")
        .replacingOccurrences(of: "@", with: ",")
        .components(separatedBy: ",")
        .compactMap(Double.init)
    pointsAndVelocities.append([.init(x: comps[0], y: comps[1], z: comps[2]), .init(x: comps[3], y: comps[4], z: comps[5])])
}

let lines = pointsAndVelocities.map(Line.with)

let lowerBound: Double = 200000000000000
let upperBound: Double = 400000000000000

var total = 0
for i in lines.indices.dropLast() {
    for j in i..<lines.endIndex {
        guard let c = lines[i].cross(with: lines[j]) else { continue }
        guard c.x >= lowerBound && c.x <= upperBound && c.y >= lowerBound && c.y <= upperBound else {
            continue
        }
        guard pointsAndVelocities[i].isFuture(c) else { continue }
        guard pointsAndVelocities[j].isFuture(c) else { continue }
        total += 1
    }
}
print(total)

let diff = CFAbsoluteTimeGetCurrent() - start
print("\(#function) Took \(diff) seconds")
