import Foundation

let input = try! String(contentsOf: URL(fileURLWithPath: "input/day22.txt"), encoding: .utf8).trimmingCharacters(in: .whitespacesAndNewlines)

struct Brick: Hashable, CustomStringConvertible {
    let x: ClosedRange<Int>
    let y: ClosedRange<Int>
    let z: ClosedRange<Int>
    
    static func parsed(_ string: String) -> Brick {
        let crd = string.replacingOccurrences(of: "~", with: ",").components(separatedBy: ",").compactMap(Int.init)
        return Brick(x: crd[0]...crd[3], y: crd[1]...crd[4], z: crd[2]...crd[5])
    }
    
    var description: String {
        "\(x),\(y),\(z)"
    }
}

let start = CFAbsoluteTimeGetCurrent()

let bricks: [Brick] = input.components(separatedBy: .newlines).filter({ !$0.isEmpty }).map(Brick.parsed)
var topBricks: [Int: [Brick]] = [
    0: [Brick(x: 0...Int.max, y: 0...Int.max, z: 0...0)]
]
var tops: [Int] = [0]
var supporting = [Brick: Set<Brick>]()
var supported = [Brick: Set<Brick>]()
for brick in bricks.sorted(by: { $0.z.lowerBound < $1.z.lowerBound }) {
    let newBottom = tops.reversed().first(where: { top in
        topBricks[top, default: []].first { $0.x.overlaps(brick.x) && $0.y.overlaps(brick.y) } != nil
    })! + 1
    let newTop = newBottom + brick.z.upperBound - brick.z.lowerBound
    if !tops.contains(newTop) {
        tops.append(newTop)
        tops.sort()
    }
    let newBrick = Brick(x: brick.x, y: brick.y, z: newBottom...newTop)
    for possibleSupport in topBricks[newBottom - 1]! where possibleSupport.x.overlaps(brick.x) && possibleSupport.y.overlaps(brick.y) {
        supporting[newBrick, default: []].insert(possibleSupport)
        supported[possibleSupport, default: []].insert(newBrick)
    }
    topBricks[newTop, default: []].append(newBrick)
}

let allUpdatedBricks = topBricks.values.flatMap({ $0 })
let canBeDeleted = allUpdatedBricks.filter {
    supported[$0, default: []].first(where: { supporting[$0, default: []].count == 1 }) == nil
}.count
print(canBeDeleted)

var allDisintegrations = 0
for brick in allUpdatedBricks.sorted(by: { $0.z.lowerBound < $1.z.lowerBound }).dropFirst() {
    var disintegrations = 0
    var queue = [brick]
    var disintegrated: Set<Brick> = []
    while !queue.isEmpty {
        let top = queue.removeFirst()
        let candidates = supported[top, default: []].filter({
            supporting[$0, default: []].subtracting(disintegrated).count == 1
        })
        disintegrations += candidates.count
        queue.append(contentsOf: candidates)
        disintegrated.insert(top)
    }
    allDisintegrations += disintegrations
}
print(allDisintegrations)

let diff = CFAbsoluteTimeGetCurrent() - start
print("\(#function) Took \(diff) seconds")
