import Foundation

let input = try! String(contentsOf: URL(fileURLWithPath: "input/day18.txt"), encoding: .utf8)

struct Cube: Hashable {
    let x, y, z: Int
    
    static func parsed(_ string: String) -> Cube {
        let comps = string.components(separatedBy: ",").compactMap(Int.init)
        return .init(x: comps[0], y: comps[1], z: comps[2])
    }
    
    var neighbours: [Cube] {
        [.init(x: x + 1, y: y, z: z), .init(x: x - 1, y: y, z: z), .init(x: x, y: y + 1, z: z), .init(x: x, y: y - 1, z: z), .init(x: x, y: y, z: z + 1), .init(x: x, y: y, z: z - 1)]
    }
}

let cubes = Set(input
    .components(separatedBy: "\n")
    .filter { !$0.isEmpty }
    .map(Cube.parsed))

func solve1() -> Int {
    cubes
        .reduce(0) { partialResult, cube in
            partialResult + (6 - cubes.intersection(cube.neighbours).count)
        }
}

func solve2() -> Int {
    let xs = cubes.map(\.x)
    let ys = cubes.map(\.y)
    let zs = cubes.map(\.z)
    let minX = xs.min()! - 1
    let maxX = xs.max()! + 1
    let minY = ys.min()! - 1
    let maxY = ys.max()! + 1
    let minZ = zs.min()! - 1
    let maxZ = zs.max()! + 1
    var reachable = Set<Cube>()
    var toProcess: Set<Cube> = [.init(x: minX, y: minY, z: minZ)]
    while !toProcess.isEmpty {
        let currentlyProcessed = toProcess.removeFirst()
        reachable.insert(currentlyProcessed)
        let neighbours = currentlyProcessed.neighbours
            .filter { !cubes.contains($0) && !reachable.contains($0) && $0.x <= maxX && $0.x >= minX && $0.y <= maxY && $0.y >= minY && $0.z <= maxZ && $0.z >= minZ }
        toProcess.formUnion(neighbours)
    }
    return cubes
        .reduce(0) { partialResult, cube in
            let neighbours = cube.neighbours
            let nonBlocking = reachable.intersection(Set(neighbours).subtracting(cubes))
            return partialResult + nonBlocking.count
        }
}

let startTime = CFAbsoluteTimeGetCurrent()

//print(solve1())
print(solve2())

let diff = CFAbsoluteTimeGetCurrent() - startTime
print("\(#function) Took \(diff) seconds")
