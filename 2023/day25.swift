import Foundation

let input = try! String(contentsOf: URL(fileURLWithPath: "input/day25.txt"), encoding: .utf8).trimmingCharacters(in: .whitespacesAndNewlines)

func solve() -> Int {
    var graph: [String: Set<String>] = [:]
    for line in input.components(separatedBy: .newlines).filter({ !$0.isEmpty }) {
        let comps = line.replacingOccurrences(of: ":", with: "").components(separatedBy: .whitespaces)
        for c in comps.dropFirst() {
            graph[comps[0], default: []].insert(c)
            graph[c, default: []].insert(comps[0])
        }
    }
    var edges = [[String]: Int]()
    for _ in 0...100 {
        let a = graph.keys.randomElement()!
        let b = graph.keys.randomElement()!
        let path = getPaths(from: a, to: b, graph: graph)
        for i in path.indices.dropLast() {
            edges[[path[i], path[i + 1]].sorted(), default: 0] += 1
        }
    }
    let three = edges.sorted(by: { $0.value > $1.value }).prefix(3)
    guard three.count == 3 else { return .max }
    return solve(keys: three.map(\.key), graph: graph) ?? .max
}

func getPaths(from a: String, to b: String, graph: [String: Set<String>]) -> [String] {
    var queue = [a]
    var processed = Set<String>()
    var predecessors: [String: String] = [:]
    var costs: [String: Int] = [a: 0]
    while !queue.isEmpty {
        let e = queue.removeFirst()
        for n in graph[e, default: []] where !processed.contains(n) {
            let newCost = costs[e, default: .max] + 1
            guard newCost < costs[n, default: .max] else { continue }
            costs[n] = newCost
            predecessors[n] = e
            queue.append(n)
        }
        processed.insert(e)
    }
    var path = [String]()
    var current: String? = b
    while current != a {
        path.append(current!)
        current = predecessors[current!]
    }
    return path
}

func analyse(_ graph: [String: Set<String>]) -> Int? {
    var toProcess = Set(graph.keys)
    var groups = [Int]()
    while !toProcess.isEmpty {
        if groups.count == 2 {
            return nil
        }
        groups.append(0)
        var queue = [toProcess.first!]
        while !queue.isEmpty {
            let element = queue.removeFirst()
            for neighbour in graph[element, default: []] where toProcess.contains(neighbour) {
                toProcess.remove(neighbour)
                queue.append(neighbour)
            }
            groups[groups.count - 1] += 1
            toProcess.remove(element)
        }
    }
    return groups.count == 2 ? groups[0] * groups[1] : nil
}

func solve(keys: [[String]], graph: [String: Set<String>]) -> Int? {
    var graph = graph
    for pair in keys {
        graph[pair[0]]?.remove(pair[1])
        graph[pair[1]]?.remove(pair[0])
    }
    return analyse(graph)
}

let start = CFAbsoluteTimeGetCurrent()

print(solve())

let diff = CFAbsoluteTimeGetCurrent() - start
print("\(#function) Took \(diff) seconds")
