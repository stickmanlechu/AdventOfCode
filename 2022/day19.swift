import Foundation

let input = try! String(contentsOf: URL(fileURLWithPath: "input/day19.txt"), encoding: .utf8)

func parseLine(_ string: String) -> (Int, [[Int]]) {
    let comps = string.replacingOccurrences(of: "Blueprint ", with: "").replacingOccurrences(of: " Each ", with: "").components(separatedBy: ":")
    let id = Int(comps[0])!
    var bp = (0..<4).map { _ in (0..<3).map { _ in 0 } }
    for costPart in comps[1].components(separatedBy: ".").enumerated() where !costPart.element.isEmpty {
        for costString in costPart.element.components(separatedBy: " robot costs ")[1].components(separatedBy: " and ").enumerated() {
            let valueAndType = costString.element.components(separatedBy: " ")
            bp[costPart.offset][costString.offset + costString.offset * (costPart.offset / 3)] = Int(valueAndType[0])!
        }
    }
    return (id, bp)
}

extension Int {
    static let oreBot = 0
    static let clayBot = 1
    static let obsiBot = 2
    static let geoBot = 3
    static let ore = 4
    static let clay = 5
    static let obsidian = 6
    static let geode = 7
    static let tick = 8
    static let oreBp = 0
    static let clayBp = 1
    static let obsiBp = 2
}

extension Array where Element == Int {
    var weightedScore: Int {
        self[.ore] + self[.clay] * 2 + self[.obsidian] * 4 + self[.geode] * 9
    }
}

final class Queue {
    struct Node {
        let data: [Int]
        let score: Int
    }
    
    private var items: [Node]
    private let prunning: Bool
    
    init(root: [Int], prunning: Bool) {
        self.items = [.init(data: root, score: 0)]
        self.prunning = prunning
    }
    
    func push(_ item: [Int]) {
        guard prunning else {
            items.append(Node(data: item, score: 0))
            return
        }
        items.append(.init(data: item, score: item.weightedScore))
        items.sort(by: { $0.score > $1.score })
        if items.count > 5000 {
            _ = items.removeLast()
        }
    }
    
    func pop() -> [Int]? {
        guard !items.isEmpty else { return nil }
        return items.removeFirst().data
    }
}

func solve(_ bp: [[Int]], maxTicks: Int, prunning: Bool = true) -> Int {
    let triangulars = (0..<maxTicks).map { ((maxTicks - $0) * (maxTicks - 1 - $0)) / 2 }
    var processed: Set<[Int]> = []
    var maxGeodes = 0
    let maxOre = bp.map(\.[.oreBp]).max()!
    let maxClay = bp.map(\.[.clayBp]).max()!
    let maxObsidian = bp.map(\.[.obsiBp]).max()!
    let toProcess = Queue(root: [1, 0, 0, 0, 0, 0, 0, 0, 0, 0], prunning: prunning)
    while let current = toProcess.pop() {
        guard processed.insert(current).inserted else { continue }
        guard current[.tick] < maxTicks else {
            maxGeodes = max(maxGeodes, current[.geode])
            continue
        }
        guard current[.geode] + (maxTicks - current[.tick]) * current[.geoBot] + triangulars[current[.tick]] > maxGeodes else { continue }
        // if can create a geode robot, go for it
        if current[.ore] >= bp[.geoBot][.oreBp] && current[.obsidian] >= bp[.geoBot][.obsiBp] {
            toProcess.push([
                current[.oreBot],
                current[.clayBot],
                current[.obsiBot],
                current[.geoBot] + 1,
                current[.ore] + current[.oreBot] - bp[3][0],
                current[.clay] + current[.clayBot],
                current[.obsidian] + current[.obsiBot] - bp[3][2],
                current[.geode] + current[.geoBot],
                current[.tick] + 1
            ])
            continue
        }
        
        // build an obsidian robot
        if current[2] < maxObsidian && current[.ore] >= bp[2][0] && current[.clay] >= bp[2][1] {
            toProcess.push([
                current[.oreBot],
                current[.clayBot],
                current[.obsiBot] + 1,
                current[.geoBot],
                current[.ore] + current[.oreBot] - bp[2][0],
                current[.clay] + current[.clayBot] - bp[2][1],
                current[.obsidian] + current[.obsiBot],
                current[.geode] + current[.geoBot],
                current[.tick] + 1
            ])
        }
        // build a clay robot
        if current[1] < maxClay && current[.ore] >= bp[1][0] {
            toProcess.push([
                current[.oreBot],
                current[.clayBot] + 1,
                current[.obsiBot],
                current[.geoBot],
                current[.ore] + current[.oreBot] - bp[1][0],
                current[.clay] + current[.clayBot],
                current[.obsidian] + current[.obsiBot],
                current[.geode] + current[.geoBot],
                current[.tick] + 1
            ])
        }
        // build an ore robot
        if current[0] < maxOre && current[.ore] >= bp[0][0] {
            toProcess.push([
                current[.oreBot] + 1,
                current[.clayBot],
                current[.obsiBot],
                current[.geoBot],
                current[.ore] + current[.oreBot] - bp[0][0],
                current[.clay] + current[.clayBot],
                current[.obsidian] + current[.obsiBot],
                current[.geode] + current[.geoBot],
                current[.tick] + 1
            ])
        }
        // don't build a robot
        toProcess.push([
            current[.oreBot],
            current[.clayBot],
            current[.obsiBot],
            current[.geoBot],
            current[.ore] + current[.oreBot],
            current[.clay] + current[.clayBot],
            current[.obsidian] + current[.obsiBot],
            current[.geode] + current[.geoBot],
            current[.tick] + 1
        ])
    }
    print(maxGeodes)
    return maxGeodes
}

func solve1() -> Int {
    input
        .components(separatedBy: "\n")
        .filter({ !$0.isEmpty })
        .compactMap(parseLine)
        .reduce(0) { partialResult, bpPair in
            partialResult + bpPair.0 * solve(bpPair.1, maxTicks: 24)
        }
}

func solve2() -> Int {
    input
        .components(separatedBy: "\n")
        .filter({ !$0.isEmpty })
        .compactMap(parseLine)
        .prefix(3)
        .reduce(1) { partialResult, bpPair in
            partialResult * solve(bpPair.1, maxTicks: 32, prunning: true)
        }
}

let startTime = CFAbsoluteTimeGetCurrent()

print(solve1())
//print(solve2())

let diff = CFAbsoluteTimeGetCurrent() - startTime
print("\(#function) Took \(diff) seconds")
