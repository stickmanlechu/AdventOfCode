import Foundation

let input = """
Time:        41     77     70     96
Distance:   249   1362   1127   1011
"""

func waysToWinRace(time: Int, distance: Int) -> Int {
    var waysToWinRace = 0
    for velocity in 0...time {
        if (time - velocity) * velocity > distance {
            waysToWinRace += 1
        }
    }
    return waysToWinRace
}

func solve1(times: [Int], distances: [Int]) -> Int {
    zip(times, distances)
        .reduce(1) {
            $0 * waysToWinRace(time: $1.0, distance: $1.1)
        }
}

func solve2() -> Int {
    waysToWinRace(time: 41777096, distance: 249136211271011)
}

let start = CFAbsoluteTimeGetCurrent()

let components = input.components(separatedBy: .newlines).filter { !$0.isEmpty }
let times = components[0].components(separatedBy: .whitespaces).dropFirst().compactMap(Int.init)
let distances = components[1].components(separatedBy: .whitespaces).dropFirst().compactMap(Int.init)

//print(solve1(times: times, distances: distances))
print(solve2())

let diff = CFAbsoluteTimeGetCurrent() - start
print("\(#function) Took \(diff) seconds")
