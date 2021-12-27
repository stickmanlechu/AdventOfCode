import Foundation

struct Row {
    let range: ClosedRange<Int>
    let letter: Character
    let password: Array<Character>
    
    var isValid: Bool {
        range.contains(password.filter { $0 == letter }.count)
    }
    
    var isValid2: Bool {
        var cnt: Int = 0
        if password[range.lowerBound - 1] == letter { cnt += 1 }
        if password[range.upperBound - 1] == letter { cnt += 1 }
        return cnt == 1
    }
    
    static func from(_ str: String) -> Row {
        let comps = str
            .replacingOccurrences(of: ":", with: "")
            .split(separator: " ")
            .map(String.init)
        let rangeComps = comps[0]
            .split(separator: "-")
            .map(String.init)
            .map { Int($0)! }
        return Self(range: rangeComps[0]...rangeComps[1], letter: Character(comps[1]), password: Array(comps[2]))
    }
}

let input = try! String(contentsOf: URL(fileURLWithPath: "input/day2.txt"), encoding: .utf8)
let rows = input
    .split(separator: "\n")
    .map(String.init)
    .map(Row.from)

func solve1() -> Int {
    return rows.filter(\.isValid).count
}

func solve2() -> Int {
    return rows.filter(\.isValid2).count
}

let start = CFAbsoluteTimeGetCurrent()

//print(solve1())
print(solve2())

let diff = CFAbsoluteTimeGetCurrent() - start
print("\(#function) Took \(diff) seconds")

