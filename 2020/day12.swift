import Foundation

enum Action {
    case n(Int)
    case s(Int)
    case e(Int)
    case w(Int)
    case l(Int)
    case r(Int)
    case f(Int)
    
    static func from(_ string: String) -> Self {
        let value = Int(string.dropFirst())!
        switch string.first! {
        case "N": return .n(value)
        case "S": return .s(value)
        case "E": return .e(value)
        case "W": return .w(value)
        case "L": return .l(value)
        case "R": return .r(value)
        case "F": return .f(value)
        default: fatalError()
        }
    }
}

enum Direction: CaseIterable {
    case east
    case south
    case west
    case north
}

func solve1(_ actions: [Action]) -> Int {
    var x = 0
    var y = 0
    var directionIndex = Direction.allCases.firstIndex(of: .east)!
    for action in actions {
        switch action {
        case .e(let value):
            x += value
        case .w(let value):
            x -= value
        case .n(let value):
            y += value
        case .s(let value):
            y -= value
        case .l(let value):
            directionIndex -= value / 90
            directionIndex = directionIndex < 0 ? (4 + directionIndex) : directionIndex
        case .r(let value):
            directionIndex = (directionIndex + value / 90) % 4
        case .f(let value):
            switch Direction.allCases[directionIndex] {
            case .east: x += value
            case .west: x -= value
            case .north: y += value
            case .south: y -= value
            }
        }
    }
    return abs(x) + abs(y)
}

func transform(_ wx: inout Int, _ wy: inout Int, by degrees: Int) {
    switch degrees {
    case -90, 270:
        let x = wx
        wx = -wy
        wy = x
    case -180,180:
        wx *= -1
        wy *= -1
    case -270, 90:
        let x = wx
        wx = wy
        wy = -x
    default:
        fatalError()
    }
}

func solve2(_ actions: [Action]) -> Int {
    var x = 0
    var y = 0
    var wx = 10
    var wy = 1
    for action in actions {
        switch action {
        case .e(let value):
            wx += value
        case .w(let value):
            wx -= value
        case .n(let value):
            wy += value
        case .s(let value):
            wy -= value
        case .l(let value):
            transform(&wx, &wy, by: -value)
        case .r(let value):
            transform(&wx, &wy, by: value)
        case .f(let value):
            x += wx * value
            y += wy * value
        }
    }
    return abs(x) + abs(y)
}

let input = try! String(contentsOf: URL(fileURLWithPath: "input/day12.txt"), encoding: .utf8)
let actions = input
    .trimmingCharacters(in: .whitespacesAndNewlines)
    .components(separatedBy: "\n")
    .map(Action.from)

let start = CFAbsoluteTimeGetCurrent()

print(solve2(actions))

let diff = CFAbsoluteTimeGetCurrent() - start
print("\(#function) Took \(diff) seconds")

