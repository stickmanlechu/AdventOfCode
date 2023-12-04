import Foundation

let input = try! String(contentsOf: URL(fileURLWithPath: "input/day4.txt"), encoding: .utf8)

func solve1() -> Int {
    input
        .components(separatedBy: "\n")
        .filter { !$0.isEmpty }
        .map {
            $0.components(separatedBy: ": ")[1]
        }
        .map { line -> Int in
            let comps = line.components(separatedBy: " | ")
            let winning = Set(comps[0].components(separatedBy: " ").compactMap(Int.init))
            let yours = Set(comps[1].components(separatedBy: " ").compactMap(Int.init))
            let overlapping = yours.intersection(winning).count
            guard overlapping > 0 else { return 0 }
            guard overlapping > 1 else { return 1 }
            return (1..<overlapping).reduce(1) { result, _ in result * 2 }
        }
        .reduce(0, +)
}

func solve2() -> Int {
    let matchingPerCard = input
        .components(separatedBy: "\n")
        .filter { !$0.isEmpty }
        .map {
            $0.components(separatedBy: ": ")[1]
        }
        .map { line -> Int in
            let comps = line.components(separatedBy: " | ")
            let winning = Set(comps[0].components(separatedBy: .whitespaces).compactMap(Int.init))
            let yours = Set(comps[1].components(separatedBy: .whitespaces).compactMap(Int.init))
            return yours.intersection(winning).count
        }
    
    var numberPerCard = matchingPerCard.map { _ in 1 }
    for card in 0..<numberPerCard.count {
        let won = matchingPerCard[card]
        guard won > 0 else {
            continue
        }
        for next in 1...won {
            let no = card + next
            guard no < numberPerCard.count else { break }
            numberPerCard[no] += numberPerCard[card]
        }
    }
    return numberPerCard.reduce(0, +)
}

let start = CFAbsoluteTimeGetCurrent()

//print(solve1())
print(solve2())

let diff = CFAbsoluteTimeGetCurrent() - start
print("\(#function) Took \(diff) seconds")
