import Foundation

func solve1(_ jolts: [Int]) -> Int {
    var ones = 0
    var threes = 1
    let sortedJolts = ([0] + jolts).sorted()
    sortedJolts
        .indices
        .dropFirst()
        .forEach { index in
            let difference = sortedJolts[index] - sortedJolts[index - 1]
            if difference == 1 {
                ones += 1
            } else if difference == 3 {
                threes += 1
            }
        }
    return ones * threes
}

func solve2(_ jolts: [Int]) -> Int {
    let sortedJolts = ([0] + jolts).sorted()
    var ways = [1]
    sortedJolts.indices.dropFirst().forEach { index in
        var i = index - 1
        var currentWays = 0
        while i >= 0 && sortedJolts[index] - sortedJolts[i] < 4 {
            currentWays += ways[i]
            i -= 1
        }
        ways.append(currentWays)
    }
    return ways.last!
}

let input = try! String(contentsOf: URL(fileURLWithPath: "input/day10.txt"), encoding: .utf8)
let jolts = input
    .trimmingCharacters(in: .whitespacesAndNewlines)
    .components(separatedBy: "\n")
    .map { Int($0)! }

let start = CFAbsoluteTimeGetCurrent()

print(solve2(jolts))

let diff = CFAbsoluteTimeGetCurrent() - start
print("\(#function) Took \(diff) seconds")
