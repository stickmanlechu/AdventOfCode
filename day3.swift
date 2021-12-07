// https://adventofcode.com/2021/day/3

import Foundation

let input = try! String(contentsOf: URL(fileURLWithPath: "input/day3.txt"), encoding: .utf8)

func toInt(_ bytes: [Int]) -> Int {
    bytes.reversed().enumerated().reduce(0) { result, byte in result + (1 << byte.offset) * byte.element }
}

func powerConsumption(numbers: [[Int]]) -> Int {
    let half = numbers.count / 2
    let gamma = (0...11).map { index in
        numbers.filter { $0[index] == 0 }.count > half ? 0 : 1
    }
    let epsilon = (0...11).map { index in
        numbers.filter { $0[index] == 0 }.count > half ? 1 : 0
    }
    return toInt(gamma) * toInt(epsilon)
}

func lifeSupport(numbers: [[Int]]) -> Int {
    return co2ScrubberRating(from: numbers) * oxygenGeneratorRating(from: numbers)
}

func co2ScrubberRating(from numbers: [[Int]]) -> Int {
    var result = numbers
    var currentIndex = 0
    while result.count > 1 {
        let zeroes = result.filter { $0[currentIndex] == 0 }
        let ones = result.filter { $0[currentIndex] == 1 }
        result = zeroes.count <= ones.count ? zeroes : ones
        currentIndex += 1
    }
    return toInt(result[0])
}

func oxygenGeneratorRating(from numbers: [[Int]]) -> Int {
    var result = numbers
    var currentIndex = 0
    while result.count > 1 {
        let zeroes = result.filter { $0[currentIndex] == 0 }
        let ones = result.filter { $0[currentIndex] == 1 }
        result = ones.count >= zeroes.count ? ones : zeroes
        currentIndex += 1
    }
    return toInt(result[0])
}

let numbers = input.split(separator: "\n")
    .map(String.init)
    .map { str in str.map { Int(String($0))! } }

let start = CFAbsoluteTimeGetCurrent()

//print(powerConsumption(numbers: numbers))
print(lifeSupport(numbers: numbers))

let diff = CFAbsoluteTimeGetCurrent() - start
print("\(#function) Took \(diff) seconds")
