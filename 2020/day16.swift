import Foundation

struct Input {
    let fieldRestrictions: [String: [ClosedRange<Int>]]
    let yourTicket: [Int]
    var nearbyTickets: [[Int]]
    
    static func parsed(from inputString: String) -> Self {
        var fieldRestrictions: [String: [ClosedRange<Int>]] = [:]
        var yourTicket: [Int] = []
        var nearbyTickets: [[Int]] = []
        var state = 0
        for line in inputString.replacingOccurrences(of: "\n\n", with: "\n").components(separatedBy: "\n") {
            guard !line.starts(with: "your ticket") else {
                state = 1
                continue
            }
            guard !line.starts(with: "nearby tickets") else {
                state = 2
                continue
            }
            switch state {
            case 0:
                let comps = line.components(separatedBy: ":")
                let ranges = comps[1].trimmingCharacters(in: .whitespaces).components(separatedBy: " or ")
                fieldRestrictions[comps[0]] = ranges
                    .map { range in
                        let nums = range.components(separatedBy: "-").map { Int($0)! }
                        return nums[0]...nums[1]
                    }
            case 1:
                yourTicket = line.components(separatedBy: ",").map { Int($0)! }
            case 2:
                nearbyTickets.append(line.components(separatedBy: ",").map { Int($0)! })
            default: fatalError()
            }
        }
        return Input(fieldRestrictions: fieldRestrictions, yourTicket: yourTicket, nearbyTickets: nearbyTickets)
    }
    
    mutating func removeInvalidNearbyTickets() {
        for index in nearbyTickets.indices.reversed() {
            let ticket = nearbyTickets[index]
            if ticket.first(where: { !fieldValid($0) }) != nil {
                nearbyTickets.remove(at: index)
            }
        }
    }
    
    func fieldValid(_ val: Int) -> Bool {
        return fieldRestrictions.first(where: { (_, ranges) in
            ranges.first(where: { $0.contains(val) }) != nil
        }) != nil
    }
    
    func solve1() -> Int {
        var errorRate = 0
        for ticket in nearbyTickets {
            for val in ticket where !fieldValid(val) {
                errorRate += val
            }
        }
        return errorRate
    }
    
    mutating func solve2() -> Int {
        removeInvalidNearbyTickets()
        var fieldName = yourTicket.indices.reduce(into: [Int: Set<String>]()) { partialResult, index in
            partialResult[index] = Set(fieldRestrictions.keys)
        }
        for ticket in nearbyTickets {
            for index in ticket.indices where fieldName[index]!.count > 1 {
                let val = ticket[index]
                for restriction in fieldRestrictions {
                    guard restriction.value.first(where: { $0.contains(val) }) == nil else { continue }
                    fieldName[index]?.remove(restriction.key)
                }
            }
        }
        var stack: [Int] = [fieldName.first(where: { $0.value.count == 1 })!.key]
        while let key = stack.popLast() {
            let toRemove = fieldName[key]!.first!
            for k in fieldName.keys where k != key && fieldName[k]!.count != 1 {
                fieldName[k]?.remove(toRemove)
                if fieldName[k]!.count == 1 {
                    stack.append(k)
                }
            }
        }
        let theKeys = fieldName.filter { $0.value.first!.starts(with: "departure") }.map { $0.key }
        return theKeys.reduce(1) { partialResult, index in
            partialResult * yourTicket[index]
        }
    }
}

let inputString = try! String(contentsOf: URL(fileURLWithPath: "input/day16.txt"), encoding: .utf8).trimmingCharacters(in: .whitespacesAndNewlines)
var input = Input.parsed(from: inputString)

let start = CFAbsoluteTimeGetCurrent()

print(input.solve2())

let diff = CFAbsoluteTimeGetCurrent() - start
print("\(#function) Took \(diff) seconds")
