import Foundation

let input = try! String(contentsOf: URL(fileURLWithPath: "input/day17.txt"), encoding: .utf8)

let chamberLeft = 0
let chamberRight = 7

struct Point: Equatable, Hashable {
    let x: Int
    let y: Int
}

enum Shape: CaseIterable {
    case iLying
    case plus
    case backwardsL
    case iStanding
    case square
    
    func startingPoints(for currentTop: Int) -> [Point] {
        switch self {
        case .iLying:
            return (2...5).map { .init(x: $0, y: currentTop + 4) }
        case .plus:
            return (2...4).map { .init(x: $0, y: currentTop + 5) } + [.init(x: 3, y: currentTop + 4), .init(x: 3, y: currentTop + 6)]
        case .backwardsL:
            return (2...4).map { .init(x: $0, y: currentTop + 4) } + (5...6).map { .init(x: 4, y: currentTop + $0) }
        case .iStanding:
            return (4...7).map { .init(x: 2, y: currentTop + $0) }
        case .square:
            return [.init(x: 2, y: currentTop + 4), .init(x: 3, y: currentTop + 4), .init(x: 2, y: currentTop + 5), .init(x: 3, y: currentTop + 5)]
        }
    }
}

var rocks = Set<Point>()

extension Array where Element == Point {
    func moved(_ push: Push) -> Self? {
        var newArray = Self()
        switch push {
        case .right:
            for point in self {
                let newPoint = Point(x: point.x + 1, y: point.y)
                guard !rocks.contains(newPoint) else { return nil }
                guard newPoint.x < chamberRight else { return nil }
                newArray.append(newPoint)
            }
        case .left:
            for point in self {
                let newPoint = Point(x: point.x - 1, y: point.y)
                guard !rocks.contains(newPoint) else { return nil }
                guard newPoint.x >= chamberLeft else { return nil }
                newArray.append(newPoint)
            }
        case .down:
            for point in self {
                let newPoint = Point(x: point.x, y: point.y - 1)
                guard !rocks.contains(newPoint) else { return nil }
                guard newPoint.y > 0 else { return nil }
                newArray.append(newPoint)
            }
        }
        return newArray
    }
}

enum Push: String {
    case right = ">"
    case left = "<"
    case down = "v"
}

func prettyPrint(currentTop: Int, falling: Set<Point> = []) {
    for row in (1...currentTop).reversed() {
        print("|", terminator: "")
        for col in chamberLeft..<chamberRight {
            let currentPoint = Point(x: col, y: row)
            if falling.contains(currentPoint) {
                print("@", terminator: "")
            } else {
                print(rocks.contains(currentPoint) ? "#" : ".", terminator: "")
            }
        }
        print("|")
    }
    print("+-------+")
}

func top100State(currentTop: Int) -> String {
    var state = ""
    for row in ((currentTop - 100)...currentTop).reversed() {
        state.append((chamberLeft..<chamberRight).map { rocks.contains(.init(x: $0, y: row)) ? "#" : "." }.joined(separator: ""))
    }
    return state
}

var top100s: [String: (round: Int, top: Int)] = [:]

func solve(rounds: Int) -> Int {
    var currentTop = 0
    var shapes = Shape.allCases
    var pushes = Array(input.trimmingCharacters(in: .whitespacesAndNewlines))
        .map(String.init)
        .compactMap(Push.init)
    for currentRound in 1...rounds {
        let newShape = shapes.removeFirst()
        shapes.append(newShape)
        var falling = newShape.startingPoints(for: currentTop)
        while true {
            let newMove = pushes.removeFirst()
            pushes.append(newMove)
            falling = falling.moved(newMove) ?? falling
            guard let newFalling = falling.moved(.down) else {
                rocks.formUnion(falling)
                currentTop = max(currentTop, falling.map(\.y).max()!)
                break
            }
            falling = newFalling
        }
        let state = top100State(currentTop: currentTop)
        guard currentTop > 100 else { continue }
        defer { top100s[state] = (currentRound, currentTop) }
        guard top100s[state] != nil else { continue }
        let topDiff = currentTop - top100s[state]!.top
        let roundDiff = currentRound - top100s[state]!.round
        guard (rounds - currentRound) % roundDiff == 0 else { continue }
        return currentTop + ((rounds - currentRound) / roundDiff) * topDiff
    }
    return currentTop
}



let startTime = CFAbsoluteTimeGetCurrent()

//print(solve(rounds: 2022))
print(solve(rounds: 1000000000000))

let diff = CFAbsoluteTimeGetCurrent() - startTime
print("\(#function) Took \(diff) seconds")
