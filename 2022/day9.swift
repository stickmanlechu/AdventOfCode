import Foundation

let input = try! String(contentsOf: URL(fileURLWithPath: "input/day9.txt"), encoding: .utf8)

struct Point: Hashable, Equatable {
    var x: Int
    var y: Int
}

func correctX(_ rope: inout [Point], _ knot: Int) {
    if rope[knot].x > rope[knot - 1].x {
        rope[knot].x -= 1
    } else if rope[knot].x < rope[knot - 1].x {
        rope[knot].x += 1
    }
}

func correctY(_ rope: inout [Point], _ knot: Int) {
    if rope[knot].y > rope[knot - 1].y {
        rope[knot].y -= 1
    } else if rope[knot].y < rope[knot - 1].y {
        rope[knot].y += 1
    }
}

func correct(_ rope: inout [Point], _ knot: Int) {
    guard abs(rope[knot].y - rope[knot - 1].y) > 1 || abs(rope[knot].x - rope[knot - 1].x) > 1 else { return }
    if rope[knot].y == rope[knot - 1].y {
        correctX(&rope, knot)
        return
    }
    if rope[knot].x == rope[knot - 1].x {
        correctY(&rope, knot)
        return
    }
    correctX(&rope, knot)
    correctY(&rope, knot)
}

func solve(_ knotCount: Int) -> Int {
    var rope: [Point] = (0..<knotCount).map { _ in .init(x: 0, y: 0) }
    var points: Set<Point> = []
    for line in input.components(separatedBy: "\n").filter({ !$0.isEmpty }) {
        let components = line.components(separatedBy: " ")
        for _ in 0..<Int(components[1])! {
            switch components[0] {
            case "U":
                rope[0].y += 1
            case "D":
                rope[0].y -= 1
            case "L":
                rope[0].x -= 1
            case "R":
                rope[0].x += 1
            default:
                assertionFailure()
            }
            for knot in rope.indices.dropFirst() {
                correct(&rope, knot)
            }
            points.insert(rope.last!)
        }
    }
    return points.count
}

let start = CFAbsoluteTimeGetCurrent()

print(solve(10))

let diff = CFAbsoluteTimeGetCurrent() - start
print("\(#function) Took \(diff) seconds")
