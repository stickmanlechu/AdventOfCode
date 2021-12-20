import Foundation

infix operator ~

struct Point: CustomStringConvertible, Hashable {
    let x: Int
    let y: Int
    let z: Int
    
    static func parse(_ str: String) -> Point {
        let comps = str.split(separator: ",").map(String.init)
        return Point(x: Int(comps[0])!, y: Int(comps[1])!, z: Int(comps[2])!)
    }
    
    static func +(lhs: Point, rhs: Point) -> Point {
        Point(x: lhs.x + rhs.x, y: lhs.y + rhs.y, z: lhs.z + rhs.z)
    }
    
    static func -(lhs: Point, rhs: Point) -> Point {
        Point(x: lhs.x - rhs.x, y: lhs.y - rhs.y, z: lhs.z - rhs.z)
    }
    
    static func ~(lhs: Point, rhs: Point) -> Int {
        abs(lhs.x - rhs.x) + abs(lhs.y - rhs.y) + abs(lhs.z - rhs.z)
    }
    
    var description: String {
        "\(x),\(y),\(z)"
    }
    
    func allOrientations() -> [Point] {
        [
            Point(x: x, y: y, z: z),
            Point(x: y, y: z, z: x),
            Point(x: z, y: x, z: y),
            Point(x: z, y: y, z: -x),
            Point(x: y, y: x, z: -z),
            Point(x: x, y: z, z: -y),
            Point(x: x, y: -y, z: -z),
            Point(x: y, y: -z, z: -x),
            Point(x: z, y: -x, z: -y),
            Point(x: z, y: -y, z: x),
            Point(x: y, y: -x, z: z),
            Point(x: x, y: -z, z: y),
            Point(x: -x, y: y, z: -z),
            Point(x: -y, y: z, z: -x),
            Point(x: -z, y: x, z: -y),
            Point(x: -z, y: y, z: x),
            Point(x: -y, y: x, z: z),
            Point(x: -x, y: z, z: y),
            Point(x: -x, y: -y, z: z),
            Point(x: -y, y: -z, z: x),
            Point(x: -z, y: -x, z: y),
            Point(x: -z, y: -y, z: -x),
            Point(x: -y, y: -x, z: -z),
            Point(x: -x, y: -z, z: -y)
        ]
    }
}

struct Scanner {
    var probes: [Point]
    var allOrientationsOfProbes: [[Point]]
    
    init(probes: [Point]) {
        self.probes = probes
        self.allOrientationsOfProbes = Self.allTransformationsApplied(to: probes)
    }
    
    mutating func addProbesAndReturnPosition(of otherScanner: Scanner) -> Point? {
        for externalProbes in otherScanner.allOrientationsOfProbes {
            var vectors = [Point: Int]()
            for centerProbe in probes {
                for externalProbe in externalProbes {
                    vectors[centerProbe - externalProbe, default: 0] += 1
                }
            }
            let candidates = vectors.filter { $0.value >= 12 }
            guard candidates.count > 0 else { continue }
            guard candidates.count == 1 else { fatalError() }
            let scannerToScannerVector = candidates.first!.key
            var allProbes = probes
            allProbes.append(contentsOf: externalProbes.map { $0 + scannerToScannerVector })
            self.probes = Array(Set(allProbes))
            self.allOrientationsOfProbes = Self.allTransformationsApplied(to: probes)
            return scannerToScannerVector
        }
        return nil
    }
    
    static func allTransformationsApplied(to probes: [Point]) -> [[Point]] {
        let pointPerms = probes.map { $0.allOrientations() }
        return (0...23).map { index in pointPerms.map { $0[index] } }
    }
}

var scanners: [Scanner] = []
var currentProbes: [Point] = []

let input = (try! String(contentsOf: URL(fileURLWithPath: "input/day19.txt"), encoding: .utf8)).trimmingCharacters(in: .whitespacesAndNewlines)
input
    .appending("\n--- end ---")
    .split(separator: "\n")
    .map(String.init)
    .forEach { line in
        guard line.starts(with: "---") else {
            currentProbes.append(Point.parse(line))
            return
        }
        guard !currentProbes.isEmpty else { return }
        scanners.append(.init(probes: currentProbes))
        currentProbes = []
        return
    }

let start = CFAbsoluteTimeGetCurrent()

var baseScanner = scanners.removeFirst()
// We assume that first scanner is our zero point
var scannerPositions = [Point(x: 0, y: 0, z: 0)]
while scanners.count > 0 {
    let anotherScanner = scanners.removeFirst()
    guard let position = baseScanner.addProbesAndReturnPosition(of: anotherScanner) else {
        scanners.append(anotherScanner)
        continue
    }
    scannerPositions.append(position)
}
print(baseScanner.probes.count)

var maxDistance = 0
for position in scannerPositions {
    for anotherPosition in scannerPositions {
        maxDistance = max(maxDistance, position ~ anotherPosition)
    }
}
print(maxDistance)

let diff = CFAbsoluteTimeGetCurrent() - start
print("\(#function) Took \(diff) seconds")
