import Foundation

let input = try! String(contentsOf: URL(fileURLWithPath: "input/day23.txt"), encoding: .utf8).trimmingCharacters(in: .whitespacesAndNewlines)

struct Point: Hashable {
    let x: Int
    let y: Int
}

struct Edge: Hashable {
    let point1: Point
    let point2: Point
}

func neighbours(of node: Point, map: [Point: String], processed: Set<Point>, ignoreSlopes: Bool = false) -> [Point] {
    if map[node] == "#" { return [] }
    let possibleNeighbours: [Point]
    switch ignoreSlopes ? "." : map[node] {
    case ".":
        possibleNeighbours = [Point(x: node.x, y: node.y - 1),
                              Point(x: node.x, y: node.y + 1),
                              Point(x: node.x + 1, y: node.y),
                              Point(x: node.x - 1, y: node.y)]
    case "<":
        possibleNeighbours = [Point(x: node.x, y: node.y - 1)]
    case ">":
        possibleNeighbours = [Point(x: node.x, y: node.y + 1)]
    case "v":
        possibleNeighbours = [Point(x: node.x + 1, y: node.y)]
    case "^":
        possibleNeighbours = [Point(x: node.x - 1, y: node.y)]
    default: return []
    }
    return possibleNeighbours
        .filter {
            map[$0, default: "#"] != "#" && !processed.contains($0)
        }
}

func solve(node: Point, graph: [Point: Set<Point>], weights: [Edge: Int], last: Point, processed: Set<Point>) -> Int {
    if node == last { return 0 }
    var processed = processed
    var result = 0
    processed.insert(node)
    for neighbour in graph[node, default: []] where !processed.contains(neighbour) {
        result = max(result, weights[.init(point1: node, point2: neighbour)]! + solve(node: neighbour, graph: graph, weights: weights, last: last, processed: processed))
    }
    return result
}

func createGraph(point: Point, graph: inout [Point: Set<Point>], weights: inout [Edge: Int], points: [Point: String], junctions: Set<Point>, last: Point, bidirectional: Bool) {
    guard point != last else { return }
    for neighbour in neighbours(of: point, map: points, processed: []) where !(neighbour.y < point.y && points[neighbour] == ">") && !(neighbour.x < point.x && points[neighbour] == "v") {
        var alreadyProcessed: Set<Point> = [point]
        var next = neighbour
        var weight = 1
        while !junctions.contains(next) {
            weight += 1
            let cur = next
            next = neighbours(of: next, map: points, processed: alreadyProcessed)[0]
            alreadyProcessed.insert(cur)
        }
        let edge = Edge(point1: point, point2: next)
        weights[edge] = weight
        graph[edge.point1, default: []].insert(edge.point2)
        if bidirectional {
            graph[edge.point2, default: []].insert(edge.point1)
            weights[.init(point1: edge.point2, point2: edge.point1)] = weight
        }
        createGraph(point: next, graph: &graph, weights: &weights, points: points, junctions: junctions, last: last, bidirectional: bidirectional)
    }
}

func solve1(points: [Point: String], first: Point, last: Point, junctions: Set<Point>) -> Int {
    var graph = [Point: Set<Point>]()
    var weights: [Edge: Int] = [:]
    
    createGraph(point: first, graph: &graph, weights: &weights, points: points, junctions: junctions, last: last, bidirectional: false)
    
    return solve(node: first, graph: graph, weights: weights, last: last, processed: [])
}

func solve2(points: [Point: String], first: Point, last: Point, junctions: Set<Point>) -> Int {
    var graph = [Point: Set<Point>]()
    var weights: [Edge: Int] = [:]
    
    createGraph(point: first, graph: &graph, weights: &weights, points: points, junctions: junctions, last: last, bidirectional: true)
    
    return solve(node: first, graph: graph, weights: weights, last: last, processed: [])
}

let start = CFAbsoluteTimeGetCurrent()

let lines = input.components(separatedBy: .newlines).filter({ !$0.isEmpty })

let points = lines
    .enumerated()
    .reduce(into: [Point: String]()) { nodes, line  in
        for (col, str) in line.element.map(String.init).enumerated() {
            nodes[.init(x: line.offset, y: col)] = str
        }
    }
let first = Point(x: 0, y: 1)
let last = Point(x: lines.count - 1, y: lines[0].count - 2)
var junctions = Set(points.keys.filter { neighbours(of: $0, map: points, processed: [], ignoreSlopes: true).count >= 3 })
junctions.insert(first)
junctions.insert(last)

print(solve1(points: points, first: first, last: last, junctions: junctions))
print(solve2(points: points, first: first, last: last, junctions: junctions))

let diff = CFAbsoluteTimeGetCurrent() - start
print("\(#function) Took \(diff) seconds")
