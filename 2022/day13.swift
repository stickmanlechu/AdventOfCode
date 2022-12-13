import Foundation

let input = try! String(contentsOf: URL(fileURLWithPath: "input/day13.txt"), encoding: .utf8)

indirect enum Element: Hashable, Equatable {
    case array([Element])
    case number(Int)
    
    var pretty: String {
        switch self {
        case .array(let elements):
            return "[\(elements.map(\.pretty).joined(separator: ","))]"
        case .number(let number):
            return "\(number)"
        }
    }
}

func parse(line: String) -> Element {
    var stack: [[Element]] = []
    var currentString: String = ""
    for char in line {
        switch char {
        case "[":
            stack.append([])
        case "]":
            if !currentString.isEmpty {
                stack[stack.count - 1].append(.number(Int(currentString)!))
                currentString = ""
            }
            let elements = stack.popLast()!
            if stack.isEmpty {
                stack.append([.array(elements)])
            } else {
                stack[stack.count - 1].append(.array(elements))
            }
        case ",":
            guard !currentString.isEmpty else { continue }
            stack[stack.count - 1].append(.number(Int(currentString)!))
            currentString = ""
        default:
            currentString.append(char)
        }
    }
    return stack.first!.first!
}

enum Order {
    case right
    case undecided
    case wrong
}

func compare(element1: Element, element2: Element) -> Order {
    switch (element1, element2) {
    case (.array(let subElements1), .array(let subElements2)):
        var i = 0
        while i < min(subElements1.count, subElements2.count) {
            let order = compare(element1: subElements1[i], element2: subElements2[i])
            if case .undecided = order {
                i += 1
                continue
            }
            return order
        }
        if i == subElements1.count && i == subElements2.count { return .undecided }
        return i == subElements1.count ? .right : .wrong
    case (.number(let num1), .number(let num2)):
        if num1 == num2 { return .undecided }
        return num1 < num2 ? .right : .wrong
    case (.number, .array):
        return compare(element1: .array([element1]), element2: element2)
    case (.array, .number):
        return compare(element1: element1, element2: .array([element2]))
    }
}

func solve1() -> Int {
    var pairStack: [Element] = []
    var index = 1
    var sum = 0
    for line in input.components(separatedBy: "\n") {
        if line.isEmpty {
            if compare(element1: pairStack[0], element2: pairStack[1]) == .right  {
                sum += index
            }
            pairStack.removeAll()
            index += 1
        } else {
            pairStack.append(parse(line: line))
        }
    }
    return sum
}

func solve2() -> Int {
    let additionalElement1 = Element.array([.number(2)])
    let additionalElement2 = Element.array([.number(6)])
    let allElements: [Element] = input.components(separatedBy: "\n").filter({ !$0.isEmpty }).map(parse) + [additionalElement1, additionalElement2]
    let sortedElements = allElements.sorted(by: { compare(element1: $0, element2: $1) == .right })
    return (sortedElements.firstIndex(of: additionalElement1)! + 1) * (sortedElements.firstIndex(of: additionalElement2)! + 1)
}

let startTime = CFAbsoluteTimeGetCurrent()

print(solve2())

let diff = CFAbsoluteTimeGetCurrent() - startTime
print("\(#function) Took \(diff) seconds")
