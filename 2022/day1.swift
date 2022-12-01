import Foundation

let input = try! String(contentsOf: URL(fileURLWithPath: "input/day1.txt"), encoding: .utf8)

extension Array where Element == Int {
    func maxAppending(_ element: Int, limit: Int) -> Array {
        Array((self + [element]).sorted().suffix(limit))
    }
}

func solve(_ maxElements: Int) -> Int {
    var maxCalories = [Int]()
    var currentCalories = 0
    for line in input.components(separatedBy: "\n") {
        guard line.isEmpty else {
            currentCalories += Int(line)!
            continue
        }
        maxCalories = maxCalories.maxAppending(currentCalories, limit: maxElements)
        currentCalories = 0
    }
    return maxCalories.maxAppending(currentCalories, limit: maxElements).reduce(0, +)
}

let start = CFAbsoluteTimeGetCurrent()

print(solve(3))

let diff = CFAbsoluteTimeGetCurrent() - start
print("\(#function) Took \(diff) seconds")
