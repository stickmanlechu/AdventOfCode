import Foundation

let input = (try! String(contentsOf: URL(fileURLWithPath: "input/day14.txt"), encoding: .utf8)).trimmingCharacters(in: .whitespacesAndNewlines)

let inputRows = input
    .split(separator: "\n")
    .map(String.init)

var template = inputRows[0]

var rules: [String: Character] = [:]
rules = inputRows
    .dropFirst()
    .reduce(into: rules) { partialResult, row in
        let comps = row
            .replacingOccurrences(of: " -> ", with: ":")
            .split(separator: ":")
            .map(String.init)
        partialResult[comps[0]] = Character(comps[1])
    }

func grow(polymer template: inout String, with rules: [String: Character]) {
    for index in template.indices.dropFirst().reversed() {
        let pair = String(template[template.index(before: index)...index])
        template.insert(rules[pair]!, at: index)
    }
}

func solve1() {
    (0..<10).forEach { step in
        grow(polymer: &template, with: rules)
    }
    let countedChars = NSCountedSet(array: Array(template))
    let sortedByFrequency = countedChars.sorted { countedChars.count(for: $0) < countedChars.count(for: $1) }
    print(countedChars.count(for: sortedByFrequency.last!) - countedChars.count(for: sortedByFrequency.first!))
}

func solve2() {
    var counts: [String: Int] = [:]
    for index in template.indices.dropFirst().reversed() {
        let pair = String(template[template.index(before: index)...index])
        counts[pair, default: 0] += 1
    }
    for _ in 1...40 {
        var newCounts: [String: Int] = [:]
        for pair in counts.keys {
            let newPart = rules[pair]
            newCounts["\(pair.first!)\(newPart!)", default: 0] += counts[pair]!
            newCounts["\(newPart!)\(pair.last!)", default: 0] += counts[pair]!
        }
        counts = newCounts
    }
    var singleCounts: [Character: Int] = [:]
    for pair in counts.keys {
        for char in pair {
            singleCounts[char, default: 0] += counts[pair]!
        }
    }
    // first and last character were counted only once,
    // thus adding those here, so that every character was counted twice
    singleCounts[template.first!, default: 0] += 1
    singleCounts[template.last!, default: 0] += 1
    
    let cnts = singleCounts.sorted { p1, p2 in
        p1.value < p2.value
    }
    
    // removing duplicates here
    print(cnts.last!.value / 2 - cnts.first!.value / 2)
}

let start = CFAbsoluteTimeGetCurrent()

//solve1()
solve2()

let diff = CFAbsoluteTimeGetCurrent() - start
print("\(#function) Took \(diff) seconds")
