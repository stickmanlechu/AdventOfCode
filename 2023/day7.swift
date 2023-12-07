import Foundation

let input = try! String(contentsOf: URL(fileURLWithPath: "input/day7.txt"), encoding: .utf8)

let cardsToPoints: [String: Int] = ["2": 0, "3": 1, "4": 2, "5": 3, "6": 4, "7": 5, "8": 6, "9": 7, "T": 8, "J": 9, "Q": 10, "K": 11, "A": 12]
let cardsToPointsJoker: [String: Int] = ["2": 0, "3": 1, "4": 2, "5": 3, "6": 4, "7": 5, "8": 6, "9": 7, "T": 8, "J": -1, "Q": 10, "K": 11, "A": 12]

enum HandType: Int, Equatable, Comparable {
    case highCard
    case onePair
    case twoPair
    case threeOfAKind
    case fullHouse
    case fourOfAKind
    case fiveOfAKind
    
    static func < (lhs: HandType, rhs: HandType) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
    
    static func type(of cards: [Int]) -> Self {
        let flattened = cards.reduce(into: [Int: Int]()) { $0[$1] = ($0[$1] ?? 0) + 1 }
        if flattened.count == 1 { return .fiveOfAKind }
        if flattened.count == 5 { return .highCard }
        if flattened.count == 4 { return .onePair }
        if flattened.count == 2 { return flattened.values.contains(4) ? .fourOfAKind : .fullHouse }
        if flattened.count == 3 { return flattened.values.contains(3) ? .threeOfAKind : .twoPair }
        fatalError()
    }
    
    static func bestType(of cards: [Int]) -> Self {
        var flattened = cards.reduce(into: [Int: Int]()) { $0[$1] = ($0[$1] ?? 0) + 1 }
        guard let jokersCount = flattened.removeValue(forKey: -1) else { return .type(of: cards) }
        switch flattened.count {
        case 0, 1: return .fiveOfAKind
        case 2 where jokersCount == 1 && flattened.values.contains(2): return .fullHouse
        case 2: return .fourOfAKind
        case 3: return .threeOfAKind
        case 4: return .onePair
        default: fatalError()
        }
    }
}

struct Hand: Comparable {
    let cards: [Int]
    let bid: Int
    let type: HandType
    let originalCards: String
    
    static func parse(_ str: String) -> Self {
        let comps = str.components(separatedBy: .whitespaces)
        let bid = Int(comps[1])!
        let cards = comps[0].map(String.init).compactMap { cardsToPoints[$0] }
        return .init(cards: cards, bid: bid, type: .type(of: cards), originalCards: comps[0])
    }
    
    static func parse2(_ str: String) -> Self {
        let comps = str.components(separatedBy: .whitespaces)
        let bid = Int(comps[1])!
        let cards = comps[0].map(String.init).compactMap { cardsToPointsJoker[$0] }
        return .init(cards: cards, bid: bid, type: .bestType(of: cards), originalCards: comps[0])
    }
    
    static func < (lhs: Hand, rhs: Hand) -> Bool {
        guard lhs.type == rhs.type else { return lhs.type < rhs.type }
        for (c1, c2) in zip(lhs.cards, rhs.cards) {
            if c1 == c2 { continue }
            return c1 < c2
        }
        return false
    }
}

let start = CFAbsoluteTimeGetCurrent()

//let hands = input.components(separatedBy: "\n").filter { !$0.isEmpty }.map(Hand.parse)
let hands = input.components(separatedBy: "\n").filter { !$0.isEmpty }.map(Hand.parse2)
let totalScore = hands
    .sorted()
    .enumerated()
    .map { ($0.offset + 1) * $0.element.bid }
    .reduce(0, +)
print(totalScore)

let diff = CFAbsoluteTimeGetCurrent() - start
print("\(#function) Took \(diff) seconds")
