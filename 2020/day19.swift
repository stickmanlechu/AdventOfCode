import Foundation

enum Pattern {
    case mix([Int])
    case or([[Int]])
    case exact(String)
}

func parse(input: String) -> ([Int: Pattern], [String]) {
    let comps = input
        .trimmingCharacters(in: .whitespacesAndNewlines)
        .components(separatedBy: "\n\n")
    
    let map = comps[0]
        .components(separatedBy: "\n")
        .map(parse(line:))
        .reduce(into: [Int: Pattern]()) { partialResult, parsedLine in
            partialResult[parsedLine.0] = parsedLine.1
        }
    
    return (map, comps[1].components(separatedBy: "\n"))
}

func parse(line: String) -> (Int, Pattern) {
    let comps = line.components(separatedBy: ":")
    let index = Int(comps[0])!
    guard !comps[1].contains("\"") else {
        return (index, .exact(comps[1].trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "\"", with: "")))
    }
    guard comps[1].contains("|") else {
        return (index, .mix(comps[1].trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: " ").map { Int($0)! }))
    }
    let ints = comps[1]
        .trimmingCharacters(in: .whitespaces)
        .components(separatedBy: "|")
        .map { g in
            g.trimmingCharacters(in: .whitespaces).components(separatedBy: " ").map { Int($0)! }
        }
    assert(ints.count == 2)
    return (index, .or(ints))
}

func pattern(for index: Int, map: [Int: Pattern]) -> String {
    switch map[index]! {
    case .exact(let value):
        return value
    case .mix(let indexes):
        return "(\(indexes.map { pattern(for: $0, map: map) }.joined()))"
    case .or(let indexGroups):
        guard indexGroups[1].contains(index) else {
            return "(\(indexGroups.map { indexes in "(\(indexes.map { pattern(for: $0, map: map) }.joined()))" }.joined(separator: "|")))"
        }
        if indexGroups[1].count == 2 {
            return "(\(indexGroups[0].map { pattern(for: $0, map: map) }.joined()))+"
        }
        guard indexGroups[1][1] == index else { fatalError() }
        let pat1 = pattern(for: indexGroups[1][0], map: map)
        let pat2 = pattern(for: indexGroups[1][2], map: map)
        return """
        (\((1...5).map { count in
            (Array(repeating: pat1, count: count) + Array(repeating: pat2, count: count)).joined()
        }.joined(separator: "|")))
        """.replacingOccurrences(of: "\n", with: "")
    }
}

func solve1(_ inputStr: String) -> Int {
    let input = parse(input: input)
    let pat = pattern(for: 0, map: input.0)
    let regex = try! NSRegularExpression(pattern: "^\(pat)$", options: [])
    
    return input.1
        .filter {
            regex.numberOfMatches(in: $0, options: [], range: .init(location: 0, length: $0.count)) == 1
        }
        .count
}

func solve2(_ inputStr: String) -> Int {
    let input = parse(input: input)
    var map = input.0
    map[8] = .or([[42], [42, 8]])
    map[11] = .or([[42, 31], [42, 11, 31]])
    let pat = pattern(for: 0, map: map)
    let regex = try! NSRegularExpression(pattern: "^\(pat)$", options: [])
    
    return input.1
        .filter {
            regex.numberOfMatches(in: $0, options: [], range: .init(location: 0, length: $0.count)) == 1
        }
        .count
}

let input = try! String(contentsOf: URL(fileURLWithPath: "input/day19.txt"), encoding: .utf8)

let start = CFAbsoluteTimeGetCurrent()

print(solve2(input))

let diff = CFAbsoluteTimeGetCurrent() - start
print("\(#function) Took \(diff) seconds")
