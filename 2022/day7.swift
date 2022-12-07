import Foundation

let input = try! String(contentsOf: URL(fileURLWithPath: "input/day7.txt"), encoding: .utf8)

final class Directory {
    let name: String
    var parent: Directory?
    var children: [String: Directory]
    var size: Int = 0
    
    init(name: String, parent: Directory?) {
        self.name = name
        self.parent = parent
        self.children = [:]
    }
}

func buildFileSystem() -> Directory {
    var currentDirectory: Directory?
    for line in input.components(separatedBy: "\n").filter({ !$0.isEmpty }) {
        if line == "$ cd .." {
            currentDirectory = currentDirectory?.parent
        } else if line.starts(with: "$ cd") {
            let directoryName = line.components(separatedBy: " ").last!
            currentDirectory = currentDirectory?.children[directoryName] ?? Directory(name: directoryName, parent: currentDirectory)
        } else if line.starts(with: "$ ls") {
            continue
        } else {
            let components = line.components(separatedBy: " ")
            if components[0] == "dir" {
                currentDirectory?.children[components[1]] = Directory(name: components[1], parent: currentDirectory)
            } else {
                currentDirectory?.size += Int(components[0])!
            }
        }
    }
    while currentDirectory?.parent != nil {
        currentDirectory = currentDirectory?.parent
    }
    return currentDirectory!
}

func solve1() -> Int {
    var totalSizes = 0
    func countSize(dir: Directory, upTo value: Int = 100000) -> Int? {
        guard !dir.children.isEmpty else {
            guard dir.size <= value else { return nil }
            totalSizes += dir.size
            return dir.size
        }
        let childrenSizes = dir.children.values.compactMap { countSize(dir: $0, upTo: value) }
        guard childrenSizes.count == dir.children.count else { return nil }
        let totalSize = dir.size + childrenSizes.reduce(0, +)
        guard totalSize <= value else { return nil }
        totalSizes += totalSize
        return totalSize
    }
    _ = countSize(dir: buildFileSystem())
    return totalSizes
}

func solve2() -> Int {
    let maxAvailable = 70000000
    let needed = 30000000
    let root = buildFileSystem()
    var sizes = [Int]()
    func totalSize(dir: Directory) -> Int {
        let s = dir.size + dir.children.values.map { totalSize(dir: $0) }.reduce(0, +)
        sizes.append(s)
        return s
    }
    let neededToDelete = needed - (maxAvailable - totalSize(dir: root))
    return sizes.filter { $0 > neededToDelete }.min()!
}

let start = CFAbsoluteTimeGetCurrent()

print(solve2())

let diff = CFAbsoluteTimeGetCurrent() - start
print("\(#function) Took \(diff) seconds")
