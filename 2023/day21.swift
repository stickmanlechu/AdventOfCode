import Foundation

let input = try! String(contentsOf: URL(fileURLWithPath: "input/day21.txt"), encoding: .utf8).trimmingCharacters(in: .whitespacesAndNewlines)

struct Node: Hashable {
    let x: Int
    let y: Int
    let graphSize: Int
    
    var index: Int {
        return x * graphSize + y
    }
    
    func neighbours(infiniteMode: Bool) -> [Node] {
        let possibleNeighbours = [Node(x: x - 1, y: y, graphSize: graphSize),
                                  Node(x: x + 1, y: y, graphSize: graphSize),
                                  Node(x: x, y: y - 1, graphSize: graphSize),
                                  Node(x: x, y: y + 1, graphSize: graphSize)]
        guard infiniteMode else {
            return possibleNeighbours.filter {
                $0.x >= 0 && $0.y >= 0 && $0.x < graphSize && $0.y < graphSize
            }
        }
        return possibleNeighbours
    }
    
    var normalised: Node {
        var y = self.y
        var x = self.x
        if y < 0 {
            y = graphSize + (y % graphSize)
        } else if y >= graphSize {
            y = y % graphSize
        }
        if x < 0 {
            x = graphSize + (x % graphSize)
        } else if x >= graphSize {
            x = x % graphSize
        }
        return Node(x: x, y: y, graphSize: graphSize)
    }
}

func help2(start: Node, stones: Set<Node>, graphSize: Int) {
    var positions: Set<Node> = [start]
    for _ in 1...(graphSize * 5 + 65) {
        let neighbours = Set(positions.flatMap({ $0.neighbours(infiniteMode: true) })
            .filter({ !stones.contains($0.normalised) }))
        positions = neighbours
    }
    let xMin = positions.min(by: { $0.x < $1.x })!.x
    let xMax = positions.max(by: { $0.x < $1.x })!.x
    let yMin = positions.min(by: { $0.y < $1.y })!.y
    let yMax = positions.max(by: { $0.y < $1.y })!.y

    print(positions.count)
    print("\(xMin) \(xMax) \(yMin) \(yMax)")
    print("\(xMax - xMin) \(yMax - yMin)")
    
    for x in xMin...xMax {
        for y in yMin...yMax {
            let node = Node(x: x, y: y, graphSize: graphSize)
            if positions.contains(node) {
                print("O", terminator: "")
            } else if stones.contains(node.normalised) {
                print("#", terminator: "")
            } else {
                print(".", terminator: "")
            }
        }
        print()
    }
}

func solve1(start: Node, stones: Set<Node>, graphSize: Int) -> Int {
    var positions: Set<Node> = [start]
    for _ in 1...64 {
        positions = Set(positions.flatMap({ $0.neighbours(infiniteMode: false) }).filter({ !stones.contains($0.normalised) }))
    }
    return positions.count
}

let start = CFAbsoluteTimeGetCurrent()

var stones = Set<Node>()
var root: Node!
let inputLines = input.components(separatedBy: .newlines).filter({ !$0.isEmpty })
let graphSize = inputLines.count
for (x, line) in inputLines.enumerated() {
    for (y, char) in line.map(String.init).enumerated() {
        let node = Node(x: x, y: y, graphSize: graphSize)
        switch char {
        case "#": stones.insert(node)
        case "S": root = node
        default: continue
        }
    }
}

print(solve1(start: root, stones: stones, graphSize: graphSize))

let diff = CFAbsoluteTimeGetCurrent() - start
print("\(#function) Took \(diff) seconds")
