import Foundation

let input = try! String(contentsOf: URL(fileURLWithPath: "input/day15.txt"), encoding: .utf8).trimmingCharacters(in: .whitespacesAndNewlines)

struct Lens: Hashable {
    let key: String
    let focalLength: Int
}

extension String {
    var boxHash: Int {
        reduce(0) { (($0 + Int($1.asciiValue!)) * 17) % 256 }
    }
}

func solve1() -> Int {
    input
        .components(separatedBy: ",")
        .map(\.boxHash)
        .reduce(0, +)
}

func solve2() -> Int {
    input.components(separatedBy: ",").reduce(into: (0 ... 255).map({ _ in [Lens]() })) { boxes, string in
        guard !string.hasSuffix("-") else {
            let key = String(string.dropLast())
            boxes[key.boxHash].removeAll(where: { $0.key == key })
            return
        }
        let comps = string.components(separatedBy: "=")
        let key = String(comps[0])
        let focalLength = Int(comps[1])!
        let boxNo = key.boxHash
        var box = boxes[boxNo]
        let lens = Lens(key: key, focalLength: focalLength)
        if let existingLensIndex = box.firstIndex(where: { $0.key == key }) {
            box[existingLensIndex] = lens
        } else {
            box.append(lens)
        }
        boxes[boxNo] = box
    }
    .enumerated()
    .map { index, box in
        box.enumerated().reduce(0) { partialResult, e in
            partialResult + (1 + index) * (e.offset + 1) * e.element.focalLength
        }
    }
    .reduce(0, +)
}

let start = CFAbsoluteTimeGetCurrent()

print(solve1())
print(solve2())

let diff = CFAbsoluteTimeGetCurrent() - start
print("\(#function) Took \(diff) seconds")
