import Foundation

func number(from string: String, max: Int = 127) -> Int {
    var l: Double = 0
    var u: Double = Double(max)
    for c in string {
        switch c {
        case "F", "L": u = l + (u - l) / 2
        case "B", "R": l = u - (u - l) / 2
        default: fatalError()
        }
    }
    return Int(u)
}

func score(for str: Array<Character>) -> Int {
    let rowString = String(str[0...6])
    let seatString = String(str[7...9])
    return number(from: rowString) * 8 + number(from: seatString, max: 7)
}

let input = try! String(contentsOf: URL(fileURLWithPath: "input/day5.txt"), encoding: .utf8)
let charArrays = input
    .split(separator: "\n")
    .map { Array($0) }

let start = CFAbsoluteTimeGetCurrent()

//print(charArrays.map(score(for:)).max()!)
let scores = charArrays
    .map(score(for:))
    .sorted()
let up = scores
    .indices
    .dropFirst()
    .first { index in
        scores[index] - scores[index - 1] > 1
    }
print(scores[up!] - 1)
