import Foundation

final class DeterministicDie {
    var current: Int = 0
    var rolled: Int = 0
    
    func roll() -> Int {
        rolled += 1
        var result = 0
        for _ in 1...3 {
            current = current == 100 ? 1 : current + 1
            result += current
        }
        return result
    }
    
    func timesRolled() -> Int {
        rolled * 3
    }
}

func part1(initialPos1: Int, initialPos2: Int) -> Int {
    let die = DeterministicDie()
    let scores = [10, 1, 2, 3, 4, 5, 6, 7, 8, 9]
    var score1 = 0
    var score2 = 0
    var pos1 = initialPos1
    var pos2 = initialPos2
    
    while true {
        let newPos1 = scores[(die.roll() + pos1) % 10]
        score1 += newPos1
        pos1 = newPos1
        guard score1 < 1000 else { break }
        let newPos2 = scores[(die.roll() + pos2) % 10]
        score2 += newPos2
        pos2 = newPos2
        guard score2 < 1000 else { break }
    }
    return die.timesRolled() * min(score1, score2)
}

final class DiracDie {
    static let possibleThreeRollSumsWithOdds: [(sum: Int, odds: Int)] = {
        let possibleOutcomes = (1...3).flatMap { n1 in (1...3).flatMap { n2 in (1...3).map { n1 + n2 + $0 } } }
        return possibleOutcomes.reduce(into: [Int: Int]()) { partialResult, outcome in
            partialResult[outcome, default: 0] += 1
        }.map { $0 }
    }()
}

func calculatePossiblePositionsAfterRoll(position: Int) -> [(position: Int, odds: Int)] {
    let scoreMap = [10, 1, 2, 3, 4, 5, 6, 7, 8, 9]
    return DiracDie.possibleThreeRollSumsWithOdds.map { (totalRoll, odds) in
        return (position: scoreMap[(position + totalRoll) % 10], odds: odds)
    }
}

func part2(positions: [Int], scores: [Int], whoRolls: Int) -> (Int, Int) {
    let prevOrNext = (whoRolls + 1) % 2
    if scores[prevOrNext] >= 21 && prevOrNext == 0 {
        return (1, 0)
    }
    if scores[prevOrNext] >= 21 && prevOrNext == 1 {
        return (0, 1)
    }
    let possibleScores = calculatePossiblePositionsAfterRoll(position: positions[whoRolls])
    return possibleScores.reduce((0, 0)) { partialResult, possibility in
        var newPositions = positions
        newPositions[whoRolls] = possibility.position
        var newScores = scores
        newScores[whoRolls] += possibility.position
        let next = part2(positions: newPositions, scores: newScores, whoRolls: prevOrNext)
        return (partialResult.0 + possibility.odds * next.0, partialResult.1 + possibility.odds * next.1)
    }
}

let input = (try! String(contentsOf: URL(fileURLWithPath: "input/day21.txt"), encoding: .utf8)).trimmingCharacters(in: .whitespacesAndNewlines)
let positions = input
    .split(separator: "\n")
    .map(String.init)
    .map { $0.replacingOccurrences(of: "Player \\d+ starting position: ", with: "", options: .regularExpression) }
    .map { Int($0)! }

let start = CFAbsoluteTimeGetCurrent()

//print(part1(initialPos1: positions[0], initialPos2: positions[1]))
let wins = part2(positions: [positions[0], positions[1]], scores: [0, 0], whoRolls: 0)
print(max(wins.0, wins.1))

let diff = CFAbsoluteTimeGetCurrent() - start
print("\(#function) Took \(diff) seconds")
