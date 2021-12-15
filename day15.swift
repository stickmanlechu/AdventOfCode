import Foundation

extension Int {
    var parentIndex: Int {
        (self - 1) / 2
    }
    
    var leftChildIndex: Int {
        2 * self + 1
    }
}

struct PriorityQueue {
    struct NodeWithPriority: Comparable {
        let node: Node
        let priority: Int
        
        static func < (lhs: NodeWithPriority, rhs: NodeWithPriority) -> Bool {
            lhs.priority < rhs.priority
        }
    }
    
    private var heap: [NodeWithPriority]
    
    init(root: Node) {
        heap = [.init(node: root, priority: 0)]
    }
    
    mutating func push(_ node: Node, priority: Int) {
        heap.append(.init(node: node, priority: priority))
        var index = heap.count - 1
        while index > 0 && heap[index.parentIndex] > heap[index] {
            heap.swapAt(index.parentIndex, index)
            index = index.parentIndex
        }
    }
    
    mutating func pop() -> Node? {
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

struct Node: Hashable {
    let x: Int
    let y: Int
    let graphSize: Int
    
    var index: Int {
        return x * graphSize + y
    }
    
    var neighbors: [Node] {
        [Node(x: x - 1, y: y, graphSize: graphSize), Node(x: x + 1, y: y, graphSize: graphSize), Node(x: x, y: y - 1, graphSize: graphSize), Node(x: x, y: y + 1, graphSize: graphSize)].filter {
            $0.x >= 0 && $0.y >= 0 && $0.x < graphSize && $0.y < graphSize
        }
    }
}

let input = (try! String(contentsOf: URL(fileURLWithPath: "input/day15.txt"), encoding: .utf8)).trimmingCharacters(in: .whitespacesAndNewlines)
let costs = input
    .split(separator: "\n")
    .map(String.init)
    .map { row in Array(row).map(String.init).map { Int($0)! } }
let fullCosts = (0...4)
    .flatMap { x in
        costs.map { row in
            row.map { ($0 + x) / 10 + ($0 + x) % 10 }
        }
    }.map { row in
        (0...4).flatMap { x in
            row.map { ($0 + x) / 10 + ($0 + x) % 10 }
        }
    }

func lowestRiskInGraph(with costs: [[Int]]) -> Int {
    let graphSize = costs.count
    var toProcess: Set<Node> = Set((0..<graphSize).flatMap { x in (0..<graphSize).map { Node(x: x, y: $0, graphSize: graphSize) } })
    var predecessors: [Int] = Array(repeating: -1, count: graphSize * graphSize)
    var lowestCost: [Int] = Array(repeating: Int.max, count: graphSize * graphSize)
    var priorityQueue = PriorityQueue(root: .init(x: 0, y: 0, graphSize: graphSize))
    lowestCost[0] = 0
    while let current = priorityQueue.pop() {
        current.neighbors
            .filter { toProcess.contains($0) }
            .forEach { node in
                let newCost = lowestCost[current.index] + costs[node.x][node.y]
                guard newCost < lowestCost[node.index] else { return }
                lowestCost[node.index] = newCost
                predecessors[node.index] = current.index
                priorityQueue.push(node, priority: newCost)
            }
        toProcess.remove(current)
    }
    return lowestCost.last!
}

let start = CFAbsoluteTimeGetCurrent()

//print(lowestRiskInGraph(with: costs))
print(lowestRiskInGraph(with: fullCosts))

let diff = CFAbsoluteTimeGetCurrent() - start
print("\(#function) Took \(diff) seconds")

