import Foundation

typealias Graph = [String: Set<String>]

extension String {
    var isSmallCave: Bool {
        lowercased() == self
    }
}

func paths(in graph: Graph, node: String, alreadyVisited: [String]) -> [String] {
    guard node != "end" else { return [node] }
    guard !(node.isSmallCave && alreadyVisited.contains(node)) else { return [] }
    return graph[node]!.flatMap { next in
        paths(in: graph, node: next, alreadyVisited: alreadyVisited + [node]).map {
            "\(node)-\($0)"
        }
    }
}

func paths2(in graph: Graph, node: String, alreadyVisited: [String], twoTimesNode: String?) -> [String] {
    guard node != "end" else { return [node] }
    guard !(node.isSmallCave && alreadyVisited.contains(node)) else { return [] }
    return graph[node]!.flatMap { next in
        paths2(in: graph, node: next, alreadyVisited: alreadyVisited + [node], twoTimesNode: twoTimesNode).map({ "\(node)-\($0)" })
        +
        ((twoTimesNode == nil && node.isSmallCave && node != "start") ?
            paths2(in: graph, node: next, alreadyVisited: alreadyVisited, twoTimesNode: node).map({ "\(node)-\($0)" }) : [])
    }
}

func numberOfUniquePaths(in graph: Graph) -> Int {
    Set(paths(in: graph, node: "start", alreadyVisited: [])).count
}

func numberOfUniquePaths2(in graph: Graph) -> Int {
    Set(paths2(in: graph, node: "start", alreadyVisited: [], twoTimesNode: nil)).count
}

let input = (try! String(contentsOf: URL(fileURLWithPath: "input/day12.txt"), encoding: .utf8)).trimmingCharacters(in: .whitespacesAndNewlines)
var graph: Graph = [:]
input
    .split(separator: "\n")
    .map(String.init)
    .forEach { edge in
        let comps = edge
            .split(separator: "-")
            .map(String.init)
        var set0 = graph[comps[0]] ?? []
        var set1 = graph[comps[1]] ?? []
        set0.insert(comps[1])
        set1.insert(comps[0])
        graph[comps[0]] = set0
        graph[comps[1]] = set1
    }

let start = CFAbsoluteTimeGetCurrent()

print(numberOfUniquePaths(in: graph))
//print(numberOfUniquePaths2(in: graph))

let diff = CFAbsoluteTimeGetCurrent() - start
print("\(#function) Took \(diff) seconds")
