import Foundation

let input = try! String(contentsOf: URL(fileURLWithPath: "input/day10.txt"), encoding: .utf8)

func possibleSteps(node: Node, value: String) -> [Node] {
    switch value {
    case "|": return [Node(row: node.row + 1, col: node.col, totalRows: node.totalRows), Node(row: node.row - 1, col: node.col, totalRows: node.totalRows)]
    case "-": return [Node(row: node.row, col: node.col - 1, totalRows: node.totalRows), Node(row: node.row, col: node.col + 1, totalRows: node.totalRows)]
    case "L": return [Node(row: node.row, col: node.col + 1, totalRows: node.totalRows), Node(row: node.row - 1, col: node.col, totalRows: node.totalRows)]
    case "J": return [Node(row: node.row - 1, col: node.col, totalRows: node.totalRows), Node(row: node.row, col: node.col - 1, totalRows: node.totalRows)]
    case "7": return [Node(row: node.row + 1, col: node.col, totalRows: node.totalRows), Node(row: node.row, col: node.col - 1, totalRows: node.totalRows)]
    case "F": return [Node(row: node.row + 1, col: node.col, totalRows: node.totalRows), Node(row: node.row, col: node.col + 1, totalRows: node.totalRows)]
    case ".": return []
    case "S": return node.allNeighbours
    default: fatalError()
    }
}

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
    let row: Int
    let col: Int
    let totalRows: Int
    
    var index: Int {
        return row * totalRows + col
    }
    
    var allNeighbours: [Node] {
        [Node(row: row - 1, col: col, totalRows: totalRows),
         Node(row: row + 1, col: col, totalRows: totalRows),
         Node(row: row, col: col - 1, totalRows: totalRows),
         Node(row: row, col: col + 1, totalRows: totalRows)]
    }
}

func enlarged(map: [[String]]) -> [[String]] {
    var newMap = (0 ..< (3 * map.count)).map { _ in
        (0..<map[0].count * 3).map { _ in
            "."
        }
    }
    for row in 0 ..< map.count {
        for col in 0 ..< map[0].count {
            let newRow = row * 3 + 1
            let newCol = col * 3 + 1
            newMap[newRow][newCol] = map[row][col]
            newMap[newRow - 1][newCol - 1] = "."
            newMap[newRow - 1][newCol] = "."
            newMap[newRow - 1][newCol + 1] = "."
            newMap[newRow][newCol - 1] = "."
            newMap[newRow][newCol + 1] = "."
            newMap[newRow + 1][newCol - 1] = "."
            newMap[newRow + 1][newCol] = "."
            newMap[newRow + 1][newCol + 1] = "."
            switch map[row][col] {
            case "-":
                newMap[newRow][newCol - 1] = "-"
                newMap[newRow][newCol + 1] = "-"
            case "L":
                newMap[newRow - 1][newCol] = "|"
                newMap[newRow][newCol + 1] = "-"
            case "7":
                newMap[newRow][newCol - 1] = "-"
                newMap[newRow + 1][newCol] = "|"
            case "J":
                newMap[newRow][newCol - 1] = "-"
                newMap[newRow - 1][newCol] = "|"
            case "F":
                newMap[newRow][newCol + 1] = "-"
                newMap[newRow + 1][newCol] = "|"
            case "|":
                newMap[newRow - 1][newCol] = "|"
                newMap[newRow + 1][newCol] = "|"
            case "S":
                newMap[newRow - 1][newCol] = "|"
                newMap[newRow][newCol - 1] = "-"
                newMap[newRow][newCol + 1] = "-"
                newMap[newRow + 1][newCol] = "|"
            default: continue
            }
        }
    }
    return newMap
}

extension Collection {
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension String {
    func isOneOf(_ other: [String]) -> Bool {
        other.contains(self)
    }
}

func costs(map: [[String]]) -> [Node: Int] {
    let totalRows = map.count
    var toProcess: Set<Node> = Set((0..<map.count).flatMap { row in (0..<map[0].count).map { Node(row: row, col: $0, totalRows: totalRows) } })
    var predecessors = [Node: Node]()
    var costs = [Node: Int]()
    var start = Node(row: 0, col: 0, totalRows: totalRows)
    while map[start.row][start.col] != "S" {
        start = .init(row: start.row + (start.col + 1) / map[0].count, col: (start.col + 1) % map[0].count, totalRows: totalRows)
    }
    var priorityQueue = PriorityQueue(root: start)
    costs[start] = 0
    while let current = priorityQueue.pop() {
        possibleSteps(node: current, value: map[current.row][current.col])
            .filter {
                toProcess.contains($0) && possibleSteps(node: $0, value: map[$0.row][$0.col]).contains(current)
            }
            .forEach { node in
                let newCost = costs[current, default: .max] + 1
                guard newCost < costs[node, default: .max] else { return }
                costs[node] = newCost
                predecessors[node] = current
                priorityQueue.push(node, priority: newCost)
            }
        toProcess.remove(current)
    }
    return costs
}

func solve1(map: [[String]]) -> Int {
    return costs(map: originalMap).values.max()!
}

func solve2(originalMap: [[String]]) -> Int {
    let map = enlarged(map: originalMap)
    let costs = costs(map: map)
    
    let totalRows = map.count
    var outsideJunk = Set<Node>()
    var possibleNestNodes = Set<Node>()
    for row in 0..<totalRows {
        for col in 0..<map[row].count {
            let node = Node(row: row, col: col, totalRows: totalRows)
            if costs[node] == nil {
                possibleNestNodes.insert(node)
            }
        }
    }
    var anythingChanged = true
    while anythingChanged {
        anythingChanged = false
        for possibleNest in possibleNestNodes {
            let neighbours = possibleNest.allNeighbours
            guard !outsideJunk.intersection(neighbours).isEmpty
                || neighbours.map(\.row).contains(-1)
                || neighbours.map(\.row).contains(totalRows)
                || neighbours.map(\.col).contains(-1)
                || neighbours.map(\.col).contains(map[0].count) else {
                continue
            }
            outsideJunk.insert(possibleNest)
            possibleNestNodes.remove(possibleNest)
            anythingChanged = true
        }
    }
    var smallMap = originalMap.map {
        $0.map { _ in " " }
    }
    for row in originalMap.indices {
        for col in originalMap[0].indices {
            let newRow = row * 3 + 1
            let newCol = col * 3 + 1
            smallMap[row][col] = possibleNestNodes.contains(.init(row: newRow, col: newCol, totalRows: totalRows)) ? "?" : map[newRow][newCol]
        }
    }
    
    return smallMap.flatMap({ $0 }).filter({ $0 == "?" }).count
}

let start = CFAbsoluteTimeGetCurrent()

let originalMap = input.components(separatedBy: .newlines)
    .filter { !$0.isEmpty }
    .map { line in
        line.map(String.init)
    }

//print(solve1(map: originalMap))
print(solve2(originalMap: originalMap))

let diff = CFAbsoluteTimeGetCurrent() - start
print("\(#function) Took \(diff) seconds")
