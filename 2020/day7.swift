import Foundation

func parse(rules: [String]) -> [String: [(count: Int, bag: String)]] {
    var bags = [String: [(count: Int, bag: String)]]()
    for rule in rules {
        let comps = rule.components(separatedBy: ":")
        if comps.count < 2 {
            print(rule)
            print(comps)
        }
        let bag = comps[0].trimmingCharacters(in: .whitespaces)
        guard !comps[1].contains("no other") else {
            bags[bag] = []
            continue
        }
        bags[bag] = comps[1].components(separatedBy: ",").map {
            let cnt = $0.replacingOccurrences(of: "[^0-9]+", with: "", options: .regularExpression).trimmingCharacters(in: .whitespaces)
            let bag = $0.replacingOccurrences(of: cnt, with: "").trimmingCharacters(in: .whitespaces)
            return (Int(cnt)!, bag)
        }
    }
    return bags
}

func solve1(bags: [String: [(Int, String)]]) -> Int {
    let bagIn = bags.reduce(into: [String: [String]]()) { partialResult, pair in
        pair.value.forEach { value in
            partialResult[value.1, default: []].append(pair.key)
        }
    }
    var alreadyCounted = Set<String>()
    defer {
        print(alreadyCounted)
    }
    return count(of: "shiny gold", in: bagIn, alreadyCounted: &alreadyCounted)
}

func count(of bag: String, in bags: [String: [String]], alreadyCounted: inout Set<String>) -> Int {
    let bagsToCheck = Set(bags[bag, default: []]).subtracting(alreadyCounted)
    guard !bagsToCheck.isEmpty else {
        return 0
    }
    alreadyCounted.formUnion(bagsToCheck)
    return bagsToCheck.count + bagsToCheck.reduce(0, { partialResult, nextBag in
        partialResult + count(of: nextBag, in: bags, alreadyCounted: &alreadyCounted)
    })
}

func solve2(bags: [String: [(Int, String)]]) -> Int {
    // -1 cause we don't want to count shiny gold as an internal bag
    return countSubbags(of: "shiny gold", rules: bags) - 1
}

func countSubbags(of bag: String, rules: [String: [(Int, String)]]) -> Int {
    let cnt = rules[bag, default: []].reduce(0) { partialResult, subbagRule in
        partialResult + subbagRule.0 * countSubbags(of: subbagRule.1, rules: rules)
    }
    print("\(bag) has \(cnt) subbags")
    return cnt + 1
}

let input = try! String(contentsOf: URL(fileURLWithPath: "input/day7.txt"), encoding: .utf8)
let rules = input
    .trimmingCharacters(in: .whitespacesAndNewlines)
    .replacingOccurrences(of: "bags", with: "")
    .replacingOccurrences(of: "contain", with: ":")
    .replacingOccurrences(of: "bag", with: "")
    .replacingOccurrences(of: ".", with: "")
    .components(separatedBy: "\n")

let bags = parse(rules: rules)

let start = CFAbsoluteTimeGetCurrent()

//print(solve1(bags: bags))
print(solve2(bags: bags))

let diff = CFAbsoluteTimeGetCurrent() - start
print("\(#function) Took \(diff) seconds")

