import Foundation

func solve1(_ input: String) -> Int {
    let lines = input
        .trimmingCharacters(in: .whitespacesAndNewlines)
        .components(separatedBy: "\n")
    let timestamp = Int(lines[0])!
    let busses = lines[1].components(separatedBy: ",").compactMap { Int($0) }
    let times = busses.map { ($0, (timestamp / $0 + (timestamp % $0 == 0 ? 0 : 1)) * $0) }
    let chosenTime = times.min(by: { $0.1 < $1.1 })!
    return chosenTime.0 * (chosenTime.1 - timestamp)
}

func solve2(_ input: String) -> Int {
    let busses = [(41, -10), (19, 12), (661, 31), (23, 54)]
    let min = 13 * 17 * 29 * 37 * 641
    var t = min
    while !busses.allSatisfy({ (t + $0.1) % $0.0 == 0 }) { t += min }
    return t - 13
}

let input = try! String(contentsOf: URL(fileURLWithPath: "input/day13.txt"), encoding: .utf8)

let start = CFAbsoluteTimeGetCurrent()

print(solve2(input))

let diff = CFAbsoluteTimeGetCurrent() - start
print("\(#function) Took \(diff) seconds")
