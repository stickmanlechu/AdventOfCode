import Foundation

let input = try! String(contentsOf: URL(fileURLWithPath: "input/day12.txt"), encoding: .utf8)

extension Collection {
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

struct Key: Hashable {
    let index: Int
    let countIndex: Int
    let brokenCount: Int
    let counts: [Int]
    let array: [String]
}

extension Array where Element == String {
    static var cachedOutcomes: [Key: Int] = [:]
    
    func outcomes(index: Int, countIndex: Int, brokenCount: Int, counts: [Int]) -> Int {
        let key = Key(index: index, countIndex: countIndex, brokenCount: brokenCount, counts: counts, array: self)
        if let value = Self.cachedOutcomes[key] {
            return value
        }
        guard index < endIndex else {
            guard countIndex >= counts.endIndex - 1 else {
                Self.cachedOutcomes[key] = 0
                return 0
            }
            let retValue = brokenCount == (counts[safe: countIndex] ?? 0) ? 1 : 0
            Self.cachedOutcomes[key] = retValue
            return retValue
        }
        var result = 0
        if self[index] == "#" || self[index] == "?" {
            result += outcomes(index: index + 1, countIndex: countIndex, brokenCount: brokenCount + 1, counts: counts)
        }
        if self[index] == "." || self[index] == "?" {
            if brokenCount == 0 {
                result += outcomes(index: index + 1, countIndex: countIndex, brokenCount: brokenCount, counts: counts)
            } else if brokenCount > 0 && countIndex < counts.endIndex && brokenCount == counts[countIndex] {
                result += outcomes(index: index + 1, countIndex: countIndex + 1, brokenCount: 0, counts: counts)
            }
        }
        Self.cachedOutcomes[key] = result
        return result
    }
}

func possibleOutcomes(for line: String, times: Int) -> Int {
    let comps = line.components(separatedBy: .whitespaces)
    let springs = (1...times).map { _ in comps[0] }.joined(separator: "?").map(String.init)
    let counts = (1...times).map { _ in comps[1] }.joined(separator: ",").components(separatedBy: ",").compactMap(Int.init)
    return springs.outcomes(index: 0, countIndex: 0, brokenCount: 0, counts: counts)
}

func solve1() -> Int {
    input.components(separatedBy: .newlines)
        .filter { !$0.isEmpty }
        .map { possibleOutcomes(for: $0, times: 1) }
        .reduce(0, +)
}

func solve2() -> Int {
    input.components(separatedBy: .newlines)
        .filter { !$0.isEmpty }
        .map { possibleOutcomes(for: $0, times: 5) }
        .reduce(0, +)
}

let start = CFAbsoluteTimeGetCurrent()

//print(solve1())
print(solve2())

let diff = CFAbsoluteTimeGetCurrent() - start
print("\(#function) Took \(diff) seconds")
