import Foundation

let input = try! String(contentsOf: URL(fileURLWithPath: "input/day4.txt"), encoding: .utf8)

extension ClosedRange<Int> {
    static func with(_ string: String) -> Self {
        let bounds = string.components(separatedBy: "-").compactMap(Int.init)
        return .init(uncheckedBounds: (bounds[0], bounds[1]))
    }
   
    func contains(_ another: Self) -> Bool {
        contains(another.lowerBound) && contains(another.upperBound)
    }
    
    func overlaps(_ another: Self) -> Bool {
        !(another.upperBound < lowerBound || upperBound < another.lowerBound)
    }
}

func solve1() -> Int {
    input
        .components(separatedBy: "\n")
        .filter { !$0.isEmpty }
        .map { $0.components(separatedBy: ",").map(ClosedRange<Int>.with) }
        .map { $0[0].contains($0[1]) || $0[1].contains($0[0]) }
        .filter { $0 }
        .count
}

func solve2() -> Int {
    input
        .components(separatedBy: "\n")
        .filter { !$0.isEmpty }
        .map { $0.components(separatedBy: ",").map(ClosedRange<Int>.with) }
        .map { $0[0].overlaps($0[1]) }
        .filter { $0 }
        .count
}

let start = CFAbsoluteTimeGetCurrent()

print(solve2())

let diff = CFAbsoluteTimeGetCurrent() - start
print("\(#function) Took \(diff) seconds")
