import Foundation

extension Character {
    static let opening: Set<Character> = ["(", "[", "{", "<"]
    
    var penalty: Int {
        switch self {
        case ")": return 3
        case "]": return 57
        case "}": return 1197
        case ">": return 25137
        default: fatalError()
        }
    }
    
    var score: Int {
        switch self {
        case ")": return 1
        case "]": return 2
        case "}": return 3
        case ">": return 4
        default: fatalError()
        }
    }
    
    var closing: Character {
        switch self {
        case "(": return Character(")")
        case "[": return Character("]")
        case "{": return Character("}")
        case "<": return Character(">")
        default: fatalError()
        }
    }
}

extension Array where Element == Int {
    var middle: Int {
        sorted()[count / 2]
    }
}

func firstWrong(in line: String) -> Character? {
    var stack: [Character] = []
    for char in line {
        guard !Character.opening.contains(char) else {
            stack.append(char)
            continue
        }
        guard let opening = stack.popLast() else { fatalError() }
        guard opening.closing == char else {
            return char
        }
    }
    return nil
}

func completionScore(for line: String) -> Int? {
    var stack: [Character] = []
    for char in line {
        guard !Character.opening.contains(char) else {
            stack.append(char)
            continue
        }
        guard let opening = stack.popLast() else { fatalError() }
        guard opening.closing == char else {
            return nil
        }
    }
    return stack
        .reversed()
        .map(\.closing.score)
        .reduce(0) { partialResult, value in
            5 * partialResult + value
        }
}

let input = (try! String(contentsOf: URL(fileURLWithPath: "input/day10.txt"), encoding: .utf8)).trimmingCharacters(in: .whitespacesAndNewlines)

let operations = input
    .split(separator: "\n")
    .map(String.init)

let start = CFAbsoluteTimeGetCurrent()

//print(operations.compactMap(firstWrong(in:)).map(\.penalty).reduce(0, +))
print(operations.compactMap(completionScore(for:)).middle)

let diff = CFAbsoluteTimeGetCurrent() - start
print("\(#function) Took \(diff) seconds")

