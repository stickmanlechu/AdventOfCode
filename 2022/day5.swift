import Foundation

let input = try! String(contentsOf: URL(fileURLWithPath: "input/day5.txt"), encoding: .utf8)

let start = CFAbsoluteTimeGetCurrent()

let movingMoreAtOnce = true

let lines = input
    .components(separatedBy: "\n")
    .filter { !$0.isEmpty }

let stackLines = lines
    .filter { !$0.starts(with: "move") }

let moveLines = lines
    .filter { $0.starts(with: "move") }

var stacks = Array(repeating: [Character](), count: stackLines.last!.filter(\.isNumber).count)
for chars in stackLines.dropLast().map(Array.init) {
    stride(from: 1, to: chars.count, by: 4)
        .filter { !chars[$0].isWhitespace }
        .forEach { stacks[($0 - 1) / 4].insert(chars[$0], at: 0) }
}

let moves = moveLines
    .map { $0.replacingOccurrences(of: "[a-z]+ ", with: "", options: .regularExpression) }
    .map { $0.components(separatedBy: " ").compactMap(Int.init) }

for move in moves {
    var removed = stacks[move[1] - 1].suffix(move[0])
    stacks[move[1] - 1].removeLast(move[0])
    while !removed.isEmpty {
        stacks[move[2] - 1].append(movingMoreAtOnce ? removed.removeFirst() : removed.removeLast())
    }
}

print(String(stacks.compactMap(\.last)))

let diff = CFAbsoluteTimeGetCurrent() - start
print("\(#function) Took \(diff) seconds")
