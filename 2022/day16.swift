import Foundation

let input = try! String(contentsOf: URL(fileURLWithPath: "input/day16.txt"), encoding: .utf8)

extension Int {
    var parentIndex: Int {
        (self - 1) / 2
    }
    
    var leftChildIndex: Int {
        2 * self + 1
    }
}

extension Array where Element: Equatable {
    func removing(_ element: Element) -> Self {
        var copyOfSelf = self
        copyOfSelf.removeAll(where: { $0 == element })
        return copyOfSelf
    }
}

struct PriorityQueue {
    struct Prioritized: Comparable {
        let node: String
        let priority: Int
        
        static func < (lhs: Prioritized, rhs: Prioritized) -> Bool {
            lhs.priority < rhs.priority
        }
    }
    
    private var heap: [Prioritized]
    
    init(root: String) {
        heap = [.init(node: root, priority: 0)]
    }
    
    mutating func push(_ node: String, priority: Int) {
        heap.append(.init(node: node, priority: priority))
        var index = heap.count - 1
        while index > 0 && heap[index.parentIndex] > heap[index] {
            heap.swapAt(index.parentIndex, index)
            index = index.parentIndex
        }
    }
    
    mutating func pop() -> String? {
        if heap.isEmpty { return nil }
        let count = heap.count
        if count == 1 { return heap.removeFirst().node }
        heapify(newRoot: count - 1)
        return heap.removeLast().node
    }
    
    private mutating func heapify(newRoot: Int) {
        var index = 0
        heap.swapAt(0, newRoot)
        while index.leftChildIndex < newRoot {
            var childIndex = index.leftChildIndex
            childIndex += (childIndex + 1 < newRoot && heap[childIndex] > heap[childIndex + 1]) ? 1 : 0
            if heap[index] <= heap[childIndex] { return }
            heap.swapAt(index, childIndex)
            index = childIndex
        }
    }
}

let lines = input
    .replacingOccurrences(of: ";[a-z ]+", with: ";", options: .regularExpression)
    .replacingOccurrences(of: "Valve ", with: "")
    .replacingOccurrences(of: " has flow rate", with: "")
    .replacingOccurrences(of: " ", with: "")
    .components(separatedBy: "\n")
    .filter { !$0.isEmpty }

typealias Path = (valve: String, weight: Int)

var flowRates: [String: Int] = [:]
var allTunnels: [String: [String]] = [:]
for line in lines {
    let components = line.components(separatedBy: ";")
    let ratePart = components[0].components(separatedBy: "=")
    flowRates[ratePart[0]] = Int(ratePart[1])!
    allTunnels[ratePart[0]] = components[1].components(separatedBy: ",")
}

var tunnels = allTunnels.reduce(into: [String: [Path]]()) { partialResult, keyValue in
    partialResult[keyValue.0] = keyValue.1.map { (valve: $0, weight: 1) }
}

for zeroPoint in flowRates.filter({ $0.value == 0 && $0.key != "AA" }).keys {
    let zeroPointTunnels = tunnels[zeroPoint]!
    tunnels[zeroPoint] = nil
    for (key, values) in tunnels where values.map(\.valve).contains(zeroPoint) {
        var newValues = values
        newValues.removeAll(where: { $0.valve == zeroPoint })
        for zeroPointTunnel in zeroPointTunnels where zeroPointTunnel.valve != key {
            guard let cur = values.first(where: { $0.valve == zeroPointTunnel.valve }) else {
                newValues.append((valve: zeroPointTunnel.valve, weight: zeroPointTunnel.weight + values.first(where: { $0.valve == zeroPoint })!.weight))
                tunnels[key] = newValues
                continue
            }
            guard cur.weight > zeroPointTunnel.weight + 1 else { continue }
            newValues.removeAll(where: { $0.valve == zeroPointTunnel.valve })
            newValues.append((valve: zeroPointTunnel.valve, weight: zeroPointTunnel.weight + 1))
            tunnels[key] = newValues
        }
    }
}

func shortestPaths(for valve: String) -> [String: Int] {
    var toProcess: Set<String> = .init(tunnels.keys)
    var lowestCost: [String: Int] = [:]
    var priorityQueue = PriorityQueue(root: valve)
    lowestCost[valve] = 0
    while let current = priorityQueue.pop() {
        tunnels[current]!
            .filter { toProcess.contains($0.valve) }
            .forEach { tunnel in
                let newCost = lowestCost[current]! + tunnel.weight
                guard newCost < lowestCost[tunnel.valve] ?? .max else { return }
                lowestCost[tunnel.valve] = newCost
                priorityQueue.push(tunnel.valve, priority: newCost)
            }
        toProcess.remove(current)
    }
    return lowestCost
}

let allShortestPaths = tunnels.keys.reduce(into: [String: [String: Int]]()) { partialResult, key in
    partialResult[key] = shortestPaths(for: key)
}

func solve(toProcess: [String], currentTime: Int, currentValve: String, maxTime: Int) -> Int {
    guard currentTime < maxTime else { return 0 }
    var newCurrentTime = currentTime
    if currentTime != 0 {
        newCurrentTime += 1
    }
    return (maxTime - newCurrentTime) * flowRates[currentValve]! + (toProcess.map {
        solve(toProcess: toProcess.removing($0), currentTime: newCurrentTime + allShortestPaths[currentValve]![$0]!, currentValve: $0, maxTime: maxTime)
    }.max() ?? 0)
}

let remaining = tunnels.keys.filter { $0 != "AA" }

func divide(_ remaining: [String]) -> [[[String]]] {
    guard !remaining.isEmpty else { return [[[], []]] }
    var remaining = remaining
    let current = remaining.removeFirst()
    var toReturn = [[[String]]]()
    for combination in divide(remaining) {
        toReturn.append([combination[0] + [current], combination[1]])
        toReturn.append([combination[0], combination[1] + [current]])
    }
    return toReturn
}


let startTime = CFAbsoluteTimeGetCurrent()

let divided = Array(Set(divide(remaining).compactMap {
    return $0[0].count >= remaining.count / 2 && $0[1].count >= remaining.count / 2 ? Set([Set($0[0]), Set($0[1])]) : nil
})).map {
    Array($0)
}

let solve2 = divided.map {
    return solve(toProcess: Array($0[0]), currentTime: 0, currentValve: "AA", maxTime: 26) + solve(toProcess: Array($0[1]), currentTime: 0, currentValve: "AA", maxTime: 26)
}.max()!
print(solve2)
//print(solve(toProcess: remaining, currentTime: 0, currentValve: "AA", maxTime: 30))


let diff = CFAbsoluteTimeGetCurrent() - startTime
print("\(#function) Took \(diff) seconds")
