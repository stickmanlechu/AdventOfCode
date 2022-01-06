import Foundation

extension Array where Element == Int {
    var score: Int {
        Array(reversed()).enumerated().reduce(0) { partialResult, card in
            partialResult + (card.offset + 1) * card.element
        }
    }
}

func solve1(_ decks: [[Int]]) -> Int {
    var deck1 = decks[0]
    var deck2 = decks[1]
    while !deck1.isEmpty && !deck2.isEmpty {
        let p1 = deck1.removeFirst()
        let p2 = deck2.removeFirst()
        if p1 > p2 {
            deck1.append(p1)
            deck1.append(p2)
        } else {
            deck2.append(p2)
            deck2.append(p1)
        }
    }
    return deck1.score + deck2.score
}

func solve2(_ decks: [[Int]]) -> Int {
    var d1 = decks[0]
    var d2 = decks[1]
    _ = play(&d1, &d2)
    return d1.score + d2.score
}

func play(_ deck1: inout [Int], _ deck2: inout [Int]) -> Int {
    var played = Set<[[Int]]>()
    while !deck1.isEmpty && !deck2.isEmpty {
        guard played.insert([deck1, deck2]).inserted else { return 1 }
        let p1 = deck1.removeFirst()
        let p2 = deck2.removeFirst()
        let player1Wins: Bool
        if p1 > deck1.count || p2 > deck2.count {
            player1Wins = p1 > p2
        } else {
            var deck1Cpy = Array(deck1.prefix(p1))
            var deck2Cpy = Array(deck2.prefix(p2))
            player1Wins = play(&deck1Cpy, &deck2Cpy) == 1
        }
        if player1Wins {
            deck1.append(p1)
            deck1.append(p2)
        } else {
            deck2.append(p2)
            deck2.append(p1)
        }
    }
    return deck1.isEmpty ? 2 : 1
}

let input = try! String(contentsOf: URL(fileURLWithPath: "input/day22.txt"), encoding: .utf8)
let decks = input
    .trimmingCharacters(in: .whitespacesAndNewlines)
    .components(separatedBy: "\n\n")
    .map { player in
        player
            .components(separatedBy: "\n")
            .dropFirst()
            .map { Int($0)! }
    }

let start = CFAbsoluteTimeGetCurrent()

//print(solve1(decks))
print(solve2(decks))

let diff = CFAbsoluteTimeGetCurrent() - start
print("\(#function) Took \(diff) seconds")
