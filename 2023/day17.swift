import Foundation

let input = try! String(contentsOf: URL(fileURLWithPath: "input/day17.txt"), encoding: .utf8).trimmingCharacters(in: .whitespacesAndNewlines)

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
    let vector: Point
    let steps: Int
    let graphSize: Point
    
    func neighbors(maxSteps: Int, minStepsToTurn: Int) -> [Node] {
        var nodes = [Node]()
        if vector.x == 0 && vector.y == 0 {
            nodes.append(.init(x: x, y: y + 1, vector: .init(x: 0, y: 1), steps: 1, graphSize: graphSize))
            nodes.append(.init(x: x + 1, y: y, vector: .init(x: 1, y: 0), steps: 1, graphSize: graphSize))
            return nodes
        }
        if steps < maxSteps {
            nodes.append(.init(x: x + vector.x, y: y + vector.y, vector: vector, steps: steps + 1, graphSize: graphSize))
        }
        if vector.y != 0 && steps >= minStepsToTurn {
            nodes.append(.init(x: x + 1, y: y, vector: .init(x: 1, y: 0), steps: 1, graphSize: graphSize))
            nodes.append(.init(x: x - 1, y: y, vector: .init(x: -1, y: 0), steps: 1, graphSize: graphSize))
        } else if vector.x != 0 && steps >= minStepsToTurn {
            nodes.append(.init(x: x, y: y + 1, vector: .init(x: 0, y: 1), steps: 1, graphSize: graphSize))
            nodes.append(.init(x: x, y: y - 1, vector: .init(x: 0, y: -1), steps: 1, graphSize: graphSize))
        }
        return nodes.filter {
            $0.x >= 0 &&
            $0.y >= 0 &&
            $0.x < graphSize.x &&
            $0.y < graphSize.y
        }
    }
}

struct Point: Hashable {
    let x: Int
    let y: Int
}

extension Node {
    var point: Point {
        .init(x: x, y: y)
    }
}

func solve(maxSteps: Int, minStepsToTurn: Int) -> Int {
    let heatMap = input.components(separatedBy: .newlines)
        .filter { !$0.isEmpty }
        .map { $0.map(String.init).compactMap(Int.init) }
    
    let graphSize = Point(x: heatMap.count, y: heatMap[0].count)
    var processed: Set<Node> = []
    let root = Node(x: 0, y: 0, vector: .init(x: 0, y: 0), steps: 0, graphSize: graphSize)
    var predecessors: [Node: Node] = .init()
    var lowestCost: [Node: Int] = .init()
    lowestCost[root] = 0
    var priorityQueue = PriorityQueue(root: root)
    while let current = priorityQueue.pop() {
        current.neighbors(maxSteps: maxSteps, minStepsToTurn: minStepsToTurn)
            .filter {
                !processed.contains($0)
            }
            .forEach { node in
                let newCost = lowestCost[current, default: .max] + heatMap[node.x][node.y]
                guard newCost < lowestCost[node, default: .max] else { return }
                lowestCost[node] = newCost
                predecessors[node] = current
                priorityQueue.push(node, priority: newCost)
            }
        processed.insert(current)
    }
    let lowestCostsOfTheLastElement = lowestCost.filter {
        $0.key.x == graphSize.x - 1 &&
        $0.key.y == graphSize.y - 1 &&
        $0.key.steps >= minStepsToTurn
    }
    return lowestCostsOfTheLastElement
        .map(\.value)
        .min() ?? .max
}

func solve1() -> Int {
    solve(maxSteps: 3, minStepsToTurn: 1)
}

func solve2() -> Int {
    solve(maxSteps: 10, minStepsToTurn: 4)
}

let start = CFAbsoluteTimeGetCurrent()

print(solve1())
print(solve2())

let diff = CFAbsoluteTimeGetCurrent() - start
print("\(#function) Took \(diff) seconds")
