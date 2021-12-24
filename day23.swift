import Foundation

typealias Amphipod = Character
typealias Cost = Int
typealias Corridor = [Amphipod?]

extension Amphipod {
    static let weights: [Character: Cost] = ["A": 1, "B": 10, "C": 100, "D": 1000]
    
    var moveCost: Cost { Self.weights[self]! }
}

extension Corridor {
    static let roomIndexes = Set([2, 4, 6, 8])
    static let roomIndexAmphipod: [Character: Int] = ["A": 2, "B": 4, "C": 6, "D": 8]
    
    func availableRoomIndexToMoveTo(from index: Int) -> Int? {
        let amphipod = self[index]!
        let roomIndex = Self.roomIndexAmphipod[amphipod]!
        guard index != roomIndex else { return index }
        let diff = index < roomIndex ? 1 : -1
        var currentIndex = index + diff
        while indices.contains(currentIndex) {
            guard self[currentIndex] == nil else { return nil }
            guard currentIndex != roomIndex else { break }
            currentIndex = currentIndex + diff
        }
        return roomIndex
    }
    
    func availableNonRoomIndexesToMoveTo(from index: Int) -> [Int] {
        var availableIndexes = [Int]()
        var currentIndex = index - 1
        while currentIndex >= 0 {
            guard self[currentIndex] == nil else { break }
            if !Self.roomIndexes.contains(currentIndex) { availableIndexes.append(currentIndex) }
            currentIndex -= 1
        }
        currentIndex = index + 1
        while currentIndex < endIndex {
            guard self[currentIndex] == nil else { break }
            if !Self.roomIndexes.contains(currentIndex) { availableIndexes.append(currentIndex) }
            currentIndex += 1
        }
        return availableIndexes
    }
}

extension Array where Element == Room {
    var isComplete: Bool { allSatisfy(\.isComplete) }
}

struct Room: Hashable {
    var amphipods: [Amphipod]
    let maxInRoom: Int
    let amphipodType: Amphipod
    
    init(amphipods: [Amphipod], amphipodType: Amphipod) {
        self.amphipods = amphipods
        self.maxInRoom = amphipods.count
        self.amphipodType = amphipodType
    }
    
    var normalized: [Amphipod?] {
        var pods: [Amphipod?] = amphipods
        (0...(maxInRoom - amphipods.count)).forEach { _ in pods.append(nil) }
        return pods
    }
    
    var isComplete: Bool {
        amphipods.count == maxInRoom && amphipods.allSatisfy { $0 == amphipodType }
    }
    
    var hasOnlyProperAmphipods: Bool {
        amphipods.allSatisfy({ $0 == amphipodType })
    }
    
    mutating func pop() -> (Amphipod, Cost)? {
        guard let amphipod = amphipods.popLast() else { return nil }
        let cost = (maxInRoom - amphipods.count) * amphipod.moveCost
        return (amphipod, cost)
    }
    
    mutating func push(_ amphipod: Amphipod) -> Cost? {
        guard amphipods.isEmpty || hasOnlyProperAmphipods else { return nil }
        let cost = (maxInRoom - amphipods.count) * amphipod.moveCost
        amphipods.append(amphipod)
        return cost
    }
}

struct State: Hashable {
    let rooms: [Room]
    let corridor: [Amphipod?]
}

var lowestCost = Int.max
var lowestState = [State]()
func updateLowestCost(_ cost: Cost, _ states: [State]) {
    if cost < lowestCost {
        lowestCost = cost
        lowestState = states
    }
}

func pretty(rooms: [Room], corridor: [Amphipod?]) -> String {
    var rows = [["\n\n#############"]]
    var max = rooms[0].maxInRoom - 1
    rows.append(["#"])
    rows[1].append(corridor.map { String($0 ?? ".") }.joined())
    rows[1].append("#")
    rows.append(["###"])
    rooms.forEach { room in rows[2].append(String(room.normalized[max] ?? ".")); rows[2].append("#") }
    rows[2].append("##")
    max -= 1
    while max >= 0 {
        rows.append(["  #"])
        rooms.forEach { room in rows[rows.count - 1].append(String(room.normalized[max] ?? ".")); rows[rows.count - 1].append("#") }
        rows[rows.count - 1].append("")
        max -= 1
    }
    rows.append(["  #########"])
    return rows.map { $0.joined() }.joined(separator: "\n")
}

var states: [State: Cost] = [:]
var failures: Set<State> = []

func solve(rooms: [Room], corridor: [Amphipod?] = Array.init(repeating: nil, count: 11), cost: Int = 0, s: [State] = []) -> Int? {
    let state = State(rooms: rooms, corridor: corridor)
    guard !failures.contains(state) else { return nil }
    if states[state, default: cost] < cost { return nil }
    states[state] = cost
    guard !rooms.isComplete else {
        updateLowestCost(cost, s + [state])
        return 0
    }
    for index in corridor.indices {
        var newRooms = rooms
        var newCorridor = corridor
        var costOfMoveToRoomIndex = 0
        if Corridor.roomIndexes.contains(index) {
            let roomIndex = index / 2 - 1
            guard !newRooms[roomIndex].hasOnlyProperAmphipods else { continue }
            guard let popped = newRooms[roomIndex].pop() else { continue }
            newCorridor[index] = popped.0
            costOfMoveToRoomIndex += popped.1
        }
        guard let amphipod = newCorridor[index] else { continue }
        guard let roomIndex = newCorridor.availableRoomIndexToMoveTo(from: index) else { continue }
        costOfMoveToRoomIndex += abs(index - roomIndex) * amphipod.moveCost
        let roomIndexInRooms = roomIndex / 2 - 1
        guard let costOfEnteringRoom = newRooms[roomIndexInRooms].push(amphipod) else { continue }
        newCorridor[index] = nil
        let additionToCost = costOfMoveToRoomIndex + costOfEnteringRoom
        guard let furtherCost = solve(rooms: newRooms, corridor: newCorridor, cost: cost + additionToCost, s: s + [state]) else { continue }
        return additionToCost + furtherCost
    }
    let toRet = rooms.enumerated().flatMap { index, room -> [Cost] in
        guard !room.hasOnlyProperAmphipods else { return [] }
        let indexInCorridor = (index + 1) * 2
        guard corridor[indexInCorridor] == nil else { return [] }
        var newRoom = room
        guard let poppedPlusCost = newRoom.pop() else { return [] }
        return corridor.availableNonRoomIndexesToMoveTo(from: indexInCorridor).compactMap { newPosition in
            var newRooms = rooms
            newRooms[index] = newRoom
            var newCorridor = corridor
            newCorridor[newPosition] = poppedPlusCost.0
            let additionToCost = poppedPlusCost.1 + (abs(newPosition - indexInCorridor) * poppedPlusCost.0.moveCost)
            guard let furtherCost = solve(rooms: newRooms, corridor: newCorridor, cost: cost + additionToCost, s: s + [state]) else { return nil }
            return additionToCost + furtherCost
        }
    }.min()
    if toRet == nil {
        failures.insert(state)
    }
    return toRet
}

let input = (try! String(contentsOf: URL(fileURLWithPath: "input/day23.txt"), encoding: .utf8)).trimmingCharacters(in: .whitespacesAndNewlines)
let allAmphipods: [Character] = input.filter(Amphipod.weights.keys.contains(_:))
let max = allAmphipods.count / 4
let amphipodsDivided = (0..<4).map { col in (0..<max).reversed().map { row in allAmphipods[row * 4 + col] } }
let rooms = Amphipod.weights
    .keys
    .sorted()
    .enumerated()
    .map { index, amphipodType in
        Room(amphipods: amphipodsDivided[index], amphipodType: amphipodType)
    }

let start = CFAbsoluteTimeGetCurrent()

print(solve(rooms: rooms) ?? -1)
for state in lowestState {
    print(pretty(rooms: state.rooms, corridor: state.corridor))
    print(states[state]!)
}

let diff = CFAbsoluteTimeGetCurrent() - start
print("\(#function) Took \(diff) seconds")
