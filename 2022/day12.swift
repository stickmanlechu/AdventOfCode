import Foundation

let input = try! String(contentsOf: URL(fileURLWithPath: "input/day12.txt"), encoding: .utf8)

struct Node: Hashable {
    let row: Int
    let col: Int
}

var grid = input.components(separatedBy: "\n").filter { !$0.isEmpty }.map { Array($0) }
var start: Node?
var end: Node?
for row in grid.indices {
    for col in grid[row].indices {
        if grid[row][col] == "S" {
            start = Node(row: row, col: col)
            grid[row][col] = "a"
        } else if grid[row][col] == "E" {
            end = Node(row: row, col: col)
            grid[row][col] = "z"
        }
    }
}
let cols = grid[0].count

func neighbors(of node: Node) -> [Node] {
    [Node(row: node.row - 1, col: node.col), Node(row: node.row + 1, col: node.col), Node(row: node.row, col: node.col - 1), Node(row: node.row, col: node.col + 1)].filter {
        $0.row >= 0 && $0.col >= 0 && $0.row < grid.count && $0.col < cols && grid[$0.row][$0.col].asciiValue! <= grid[node.row][node.col].asciiValue! + 1
    }
}

func shortestPath(with grid: [[Character]], start: Node) -> Int {
    var toProcess: Set<Node> = Set(grid.indices.flatMap { row in grid[row].indices.map { Node(row: row, col: $0) } })
    var lowestCost = grid.map { $0.map { _ in Int.max} }
    var priorityQueue = [start]
    lowestCost[start.row][start.col] = 0
    while !priorityQueue.isEmpty {
        let current = priorityQueue.removeFirst()
        neighbors(of: current)
            .filter { toProcess.contains($0) }
            .forEach { node in
                let newCost = lowestCost[current.row][current.col] + 1
                guard newCost < lowestCost[node.row][node.col] else { return }
                lowestCost[node.row][node.col] = newCost
                priorityQueue.append(node)
            }
        toProcess.remove(current)
    }
    return lowestCost[end!.row][end!.col]
}

func solve1() -> Int {
    shortestPath(with: grid, start: start!)
}

func solve2() -> Int {
    var possibleStarts = [Node]()
    for row in grid.indices {
        for col in grid[row].indices {
            guard grid[row][col] == "a" else { continue }
            possibleStarts.append(.init(row: row, col: col))
        }
    }
    return possibleStarts.map { shortestPath(with: grid, start: $0) }.min()!
}

let startTime = CFAbsoluteTimeGetCurrent()

print(solve2())

let diff = CFAbsoluteTimeGetCurrent() - startTime
print("\(#function) Took \(diff) seconds")
