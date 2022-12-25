import Foundation

let input = try! String(contentsOf: URL(fileURLWithPath: "input/day25.txt"), encoding: .utf8)

extension Character {
    var int: Int {
        switch self {
        case "0": return 0
        case "1": return 1
        case "2": return 2
        case "-": return -1
        default: return -2
        }
    }
}

extension String {
    func snafuToInt() -> Int {
        Array(self)
            .reversed()
            .enumerated()
            .map {
                NSDecimalNumber(decimal: pow(5, $0.offset)).intValue * $0.element.int
            }
            .reduce(0, +)
    }
}

extension Int {
    func asSnafu() -> String {
        var num = self
        var snafu = ""
        while num > 0 {
            let remainder = num % 5
            snafu = ["0", "1", "2", "=", "-", "0"][remainder] + snafu
            num = num / 5 + (remainder / 3)
        }
        return snafu
    }
}

func solve() -> String {
    input
        .components(separatedBy: "\n")
        .filter { !$0.isEmpty }
        .map { $0.snafuToInt() }
        .reduce(0, +)
        .asSnafu()
}

let startTime = CFAbsoluteTimeGetCurrent()

print(solve())

let diff = CFAbsoluteTimeGetCurrent() - startTime
print("\(#function) Took \(diff) seconds")
