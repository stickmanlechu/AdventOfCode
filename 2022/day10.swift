import Foundation

let input = try! String(contentsOf: URL(fileURLWithPath: "input/day10.txt"), encoding: .utf8)

let start = CFAbsoluteTimeGetCurrent()

var x = 1
var cycles = 0
var sum = 0
var pixel = 0
let interestingCycles: Set<Int> = [20, 60, 100, 140, 180, 220]
var screen = (0..<240).map { _ in " " }

for line in input.components(separatedBy: "\n").filter({ !$0.isEmpty }) {
    var cycleInc = 1
    var xInc = 0
    if line.starts(with: "addx") {
        cycleInc += 1
        xInc = Int(line.components(separatedBy: " ")[1])!
    }
    let xSet: Set<Int> = [x - 1, x, x + 1]
    for i in 0..<cycleInc {
        cycles += 1
        if xSet.contains(pixel % 40) { screen[pixel] = "#" }
        if interestingCycles.contains(cycles) { sum += x * cycles }
        if i == 1 { x += xInc }
        pixel += 1
    }
}
print(sum)
for row in 0...5 {
    print(screen[(row * 40)..<((row + 1) * 40)].joined())
}

let diff = CFAbsoluteTimeGetCurrent() - start
print("\(#function) Took \(diff) seconds")
