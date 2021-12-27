import Foundation

let input = try! String(contentsOf: URL(fileURLWithPath: "input/day1.txt"), encoding: .utf8)

func solve(measurements: [Int], windowSize: Int) -> Int {
    measurements.indices
        .dropFirst(windowSize)
        .reduce(0) { result, index in
            measurements[index - windowSize] < measurements[index] ? result + 1 : result
        }
}

let measurements = input
    .split(separator: "\n")
    .map(String.init)
    .map { Int($0)! }

let start = CFAbsoluteTimeGetCurrent()

print(solve(measurements: measurements, windowSize: 3))

let diff = CFAbsoluteTimeGetCurrent() - start
print("\(#function) Took \(diff) seconds")
