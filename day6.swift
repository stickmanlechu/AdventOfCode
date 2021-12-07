// https://adventofcode.com/2021/day/6

import Foundation

let input = (try! String(contentsOf: URL(fileURLWithPath: "input/day6.txt"), encoding: .utf8)).trimmingCharacters(in: .whitespacesAndNewlines)

let fish = input.split(separator: ",")
    .map(String.init)
    .map { Int($0)! }

func simulate(fish: [Int], after days: Int) {
    var counters: [Int] = (0...8).map { _ in 0 }
    Set(fish).forEach { counter in counters[counter] = fish.filter { $0 == counter }.count }
    for _ in 1...days {
        let newFish = counters.removeFirst()
        counters.append(newFish)
        counters[6] += newFish
    }
    print(counters.reduce(0, +))
}

let start = CFAbsoluteTimeGetCurrent()

//simulate(fish: fish, after: 80)
simulate(fish: fish, after: 256)

let diff = CFAbsoluteTimeGetCurrent() - start
print("\(#function) Took \(diff) seconds")

