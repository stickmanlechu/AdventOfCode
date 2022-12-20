import Foundation

let input = try! String(contentsOf: URL(fileURLWithPath: "input/day20.txt"), encoding: .utf8)

struct Node: Hashable {
    let value: Int
    let originalIndex: Int
}

func solve(decryptionKey: Int, mixes: Int) -> Int {
    var numbers = input
        .components(separatedBy: "\n")
        .filter({ !$0.isEmpty })
        .compactMap(Int.init)
        .enumerated()
        .map {
            Node(value: $0.element * decryptionKey, originalIndex: $0.offset)
        }
    let originalStack = numbers
    var zero: Node?
    for _ in 0..<mixes {
        var stack = originalStack
        while !stack.isEmpty {
            let element = stack.removeFirst()
            guard element.value != 0 else {
                zero = element
                continue
            }
            let currentIndex = numbers.firstIndex(of: element)!
            var prevIndex = currentIndex == 0 ? numbers.count - 1 : currentIndex - 1
            var nextIndex = (currentIndex + 1) % numbers.count
            numbers.remove(at: currentIndex)
            if prevIndex > currentIndex {
                prevIndex -= 1
            }
            if nextIndex > currentIndex {
                nextIndex -= 1
            }
            prevIndex = (prevIndex + element.value) % numbers.count
            nextIndex = (nextIndex + element.value) % numbers.count
            if element.value < 0 {
                prevIndex = prevIndex < 0 ? numbers.count + prevIndex : prevIndex
                nextIndex = nextIndex < 0 ? numbers.count + nextIndex : nextIndex
            }
            if prevIndex < nextIndex {
                numbers.insert(element, at: prevIndex + 1)
            } else {
                numbers.insert(element, at: 0)
            }
        }
    }
    let zeroIndex = numbers.firstIndex(of: zero!)!
    return [1000, 2000, 3000].reduce(0) { partialResult, diff in
        partialResult + numbers[(zeroIndex + diff) % numbers.count].value
    }
}

let startTime = CFAbsoluteTimeGetCurrent()

//print(solve(decryptionKey: 1, mixes: 1))
print(solve(decryptionKey: 811589153, mixes: 10))

let diff = CFAbsoluteTimeGetCurrent() - startTime
print("\(#function) Took \(diff) seconds")
