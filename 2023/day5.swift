import Foundation

let input = try! String(contentsOf: URL(fileURLWithPath: "input/day5.txt"), encoding: .utf8)

struct Mapping {
    let source: Int
    let target: Int
}

extension ClosedRange where Element == Int {
    func contains(_ another: Self) -> Bool {
        contains(another.lowerBound) && contains(another.upperBound)
    }
    
    func removing(_ another: Self) -> [Self] {
        guard self.overlaps(another) else { return [self] }
        guard !another.contains(self) else { return [] }
        if another.lowerBound <= lowerBound {
            return [(another.upperBound + 1)...upperBound]
        }
        if another.upperBound >= upperBound {
            return [lowerBound...(another.lowerBound - 1)]
        }
        return [
            lowerBound...(another.lowerBound - 1),
            (another.upperBound + 1)...upperBound
        ]
    }
}

func solve(seedsInRanges: Bool) -> Int {
    let sections = input.components(separatedBy: "\n\n")
    
    var maps = [[ClosedRange<Int>: Mapping]]()
    for section in sections.dropFirst() {
        var sectionMap = [ClosedRange<Int>: Mapping]()
        for row in section.components(separatedBy: "\n").dropFirst().filter({ !$0.isEmpty }) {
            let values = row.components(separatedBy: .whitespaces).compactMap(Int.init)
            let range = values[1]...(values[1] + values[2] - 1)
            sectionMap[range] = Mapping(source: values[1], target: values[0])
        }
        maps.append(sectionMap)
    }
    
    let seeds = sections[0].replacingOccurrences(of: "seeds: ", with: "").components(separatedBy: .whitespaces).compactMap(Int.init)
    var seedsRanges = [ClosedRange<Int>]()
    if seedsInRanges {
        for index in stride(from: 0, to: seeds.count, by: 2) {
            seedsRanges.append(seeds[index]...(seeds[index] + seeds[index + 1] - 1))
        }
    } else {
        for seed in seeds {
            seedsRanges.append(seed...seed)
        }
    }
    
    var locations = [Int]()
    for seedRange in seedsRanges {
        var inputRanges = [seedRange]
        for map in maps {
            var localInputRanges = [ClosedRange<Int>]()
            for inputRange in inputRanges {
                var notMatched = [inputRange]
                for matchingMapping in map.filter({ $0.key.overlaps(inputRange) }) {
                    let intersection = inputRange.clamped(to: matchingMapping.key)
                    let start = matchingMapping.value.target + intersection.lowerBound - matchingMapping.value.source
                    let end = matchingMapping.value.target + intersection.upperBound - matchingMapping.value.source
                    localInputRanges.append(start...end)
                    notMatched = notMatched.flatMap { $0.removing(intersection) }
                }
                localInputRanges.append(contentsOf: notMatched)
            }
            inputRanges = localInputRanges
        }
        locations.append(inputRanges.min(by: { $0.lowerBound < $1.lowerBound })!.lowerBound)
    }
    return locations.min()!
}

let start = CFAbsoluteTimeGetCurrent()

print(solve(seedsInRanges: true))

let diff = CFAbsoluteTimeGetCurrent() - start
print("\(#function) Took \(diff) seconds")
