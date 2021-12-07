// https://adventofcode.com/2021/day/7

import Foundation

let input = (try! String(contentsOf: URL(fileURLWithPath: "input/day7.txt"), encoding: .utf8)).trimmingCharacters(in: .whitespacesAndNewlines)

func fuel2(pos1: Int, pos2: Int) -> Int {
    abs(pos2-pos1)
}

func fuel1(pos1: Int, pos2: Int) -> Int {
    let n = abs(pos2-pos1)
    return n * (1 + n)/2
}

let positions: [Int] = input
    .split(separator: ",")
    .map(String.init)
    .map { Int($0)! }

var alreadyCalculated = [Int: Int]()

func find(left: Int, right: Int) {
    if left == right {
        print(positions.reduce(0) { partialResult, pos in
            partialResult + fuel1(pos1: left, pos2: pos)
        })
        return
    }
    let fLeft = alreadyCalculated[left] ?? positions.reduce(0) { partialResult, pos in
        partialResult + fuel1(pos1: left, pos2: pos)
    }
    alreadyCalculated[left] = fLeft
    let fRight = alreadyCalculated[right] ?? positions.reduce(0) { partialResult, pos in
        partialResult + fuel1(pos1: right, pos2: pos)
    }
    alreadyCalculated[right] = fRight
    if fLeft < fRight {
        find(left: left, right: Int(floor(Double(left + right)/2.0)))
    } else {
        find(left: Int(ceil(Double(left + right)/2.0)), right: right)
    }
}

let start = CFAbsoluteTimeGetCurrent()

find(left: positions.min()!, right: positions.max()!)

let diff = CFAbsoluteTimeGetCurrent() - start
print("\(#function) Took \(diff) seconds")
