import Foundation

indirect enum SNumber: Hashable {
    case pair(SNumber, SNumber)
    case regular(Int)
    
    var magnitude: Int {
        switch self {
        case .regular(let value): return value
        case .pair(let left, let right): return 3 * left.magnitude + 2 * right.magnitude
        }
    }
    
    mutating func reduce() {
        while true {
            guard explode() != nil || split() else { return }
        }
    }
    
    private mutating func explode(lvl: Int = 1) -> (left: Int, right: Int)? {
        switch self {
        case .regular: return nil
        case .pair(.regular(let left), .regular(let right)) where lvl > 4:
            self = .regular(0)
            return (left: left, right: right)
        case .pair(var left, var right):
            defer {
                self = .pair(left, right)
            }
            if let exploded = left.explode(lvl: lvl + 1) {
                if right.tryPropagateExploded(value: exploded.right) {
                    return (left: exploded.left, right: 0)
                }
                return exploded
            }
            guard let exploded = right.explode(lvl: lvl + 1) else { return nil }
            switch left {
            case .pair:
                if left.tryPropagateExploded(value: exploded.left, preferRight: true) {
                    return (left: 0, right: exploded.right)
                }
            default:
                if left.tryPropagateExploded(value: exploded.left) {
                    return (left: 0, right: exploded.right)
                }
            }
            return exploded
        }
    }
    
    private mutating func tryPropagateExploded(value: Int, preferRight: Bool = false) -> Bool {
        switch self {
        case .regular(let x):
            self = .regular(x + value)
            return true
        case .pair(var left, var right):
            defer { self = .pair(left, right) }
            if preferRight { return right.tryPropagateExploded(value: value, preferRight: preferRight) }
            return left.tryPropagateExploded(value: value)
        }
    }
    
    private mutating func split() -> Bool {
        switch self {
        case .pair(var left, var right):
            defer { self = .pair(left, right) }
            return left.split() || right.split()
        case .regular(let value):
            guard value > 9 else { return false }
            let dValue = Double(value)
            self = .pair(.regular(Int(floor(dValue / 2))), .regular(Int(ceil(dValue / 2))))
            return true
        }
    }
}

extension SNumber: CustomStringConvertible {
    var description: String {
        switch self {
        case .regular(let value):
            return "\(value)"
        case .pair(let n1, let n2):
            return "[\(n1),\(n2)]"
        }
    }
}

func parse(line: String) -> SNumber {
    var stack: [SNumber] = []
    for char in line {
        switch char {
        case "[": continue
        case "]":
            let right = stack.popLast()!
            let left = stack.popLast()!
            stack.append(.pair(left, right))
        case ",": continue
        default: stack.append(.regular(Int(String(char))!))
        }
    }
    return stack.first!
}

let input = (try! String(contentsOf: URL(fileURLWithPath: "input/day18.txt"), encoding: .utf8)).trimmingCharacters(in: .whitespacesAndNewlines)
let numbers = input
    .split(separator: "\n")
    .map(String.init)
    .map(parse(line:))

let start = CFAbsoluteTimeGetCurrent()

//var result: SNumber = numbers[0]
//for number in numbers.dropFirst() {
//    result = .pair(result, number)
//    result.reduce()
//}
//print(result.magnitude)
var highest = 0
(0..<numbers.count).forEach { index in
    (0..<numbers.count).filter { $0 != index }.forEach {
        var n = SNumber.pair(numbers[index], numbers[$0])
        n.reduce()
        highest = max(highest, n.magnitude)
    }
}
print(highest)

let diff = CFAbsoluteTimeGetCurrent() - start
print("\(#function) Took \(diff) seconds")

