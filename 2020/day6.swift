import Foundation

extension String {
    var removingNewlines: String {
        replacingOccurrences(of: "\n", with: "")
    }
}

func solve1(_ groups: [String]) -> Int {
    groups.reduce(0) { partialResult, str in
        partialResult + Set(Array(str.removingNewlines)).count
    }
}

func solve2(_ groups: [String]) -> Int {
    groups.reduce(0) { partialResult, str in
        partialResult + str.split(separator: "\n").reduce(into: Set<Character>(str.removingNewlines), { partialResult, sub in
            partialResult.formIntersection(Array(sub))
        }).count
    }
}

let input = try! String(contentsOf: URL(fileURLWithPath: "input/day6.txt"), encoding: .utf8)
let groups = input.components(separatedBy: "\n\n")

let start = CFAbsoluteTimeGetCurrent()

//print(solve1(groups))
print(solve2(groups))

let diff = CFAbsoluteTimeGetCurrent() - start
print("\(#function) Took \(diff) seconds")
