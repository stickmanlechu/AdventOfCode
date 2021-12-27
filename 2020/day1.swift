import Foundation

let input = try! String(contentsOf: URL(fileURLWithPath: "input/day1.txt"), encoding: .utf8)

let numbers = input
    .split(separator: "\n")
    .map(String.init)
    .map { Int($0)! }

func solve1() -> Int {
    for n1 in numbers {
        let candidate = 2020 - n1
        guard let n2 = numbers.first(where: { $0 == candidate }) else { continue }
        return n1 * n2
    }
    fatalError()
}

func solve2() -> Int {
    for n1 in numbers {
        for n2 in numbers {
            let candidate = 2020 - n1 - n2
            guard let n3 = numbers.first(where: { $0 == candidate }) else { continue }
            return n1 * n2 * n3
        }
    }
    fatalError()
}

let start = CFAbsoluteTimeGetCurrent()

//print(solve1())
print(solve2())

let diff = CFAbsoluteTimeGetCurrent() - start
print("\(#function) Took \(diff) seconds")

