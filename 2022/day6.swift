import Foundation

let input = try! String(contentsOf: URL(fileURLWithPath: "input/day6.txt"), encoding: .utf8)

func solve(packetLength: Int) -> Int {
    let chars = Array(input)
    for i in 0...(chars.count - packetLength) {
        var set = Set<Character>()
        if (i...(i + packetLength - 1)).first(where: { !set.insert(chars[$0]).0 }) == nil { return i + packetLength }
    }
    return -1
}

let start = CFAbsoluteTimeGetCurrent()

print(solve(packetLength: 14))

let diff = CFAbsoluteTimeGetCurrent() - start
print("\(#function) Took \(diff) seconds")
