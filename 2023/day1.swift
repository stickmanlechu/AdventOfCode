import Foundation

let input = try! String(contentsOf: URL(fileURLWithPath: "input/day1.txt"), encoding: .utf8)

extension String {
    static let mapping = ["one": "1", "two": "2", "three": "3", "four": "4", "five": "5", "six": "6", "seven": "7", "eight": "8", "nine": "9",
                          "1": "1", "2": "2", "3": "3", "4": "4", "5": "5", "6": "6", "7": "7", "8": "8", "9": "9"]
    
    static let regexes = mapping.keys.compactMap { try? Regex($0) }
    
    var solve2: Int {
        let allRanges = Self.regexes
            .flatMap { self.matches(of: $0).map(\.range) }
            .sorted(by: { $0.lowerBound < $1.lowerBound })
        let ranges = [allRanges.first!, allRanges.last!]
        return Int(ranges
            .compactMap { String.mapping[String(self[$0])] }
            .joined())!
    }
}

func solve1(_ input: [String]) -> Int {
    input
        .map { line in line.filter(\.isNumber) }
        .compactMap { Int(String($0.first!) + String($0.last!)) }
        .reduce(0, +)
}

func solve2(_ input: [String]) -> Int {
    input
        .map(\.solve2)
        .reduce(0, +)
}

let start = CFAbsoluteTimeGetCurrent()

let lines: [String] = input
    .components(separatedBy: "\n")
    .filter { !$0.isEmpty }

//print(solve1(lines))
print(solve2(lines))

let diff = CFAbsoluteTimeGetCurrent() - start
print("\(#function) Took \(diff) seconds")
