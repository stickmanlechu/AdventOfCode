import Foundation

let input = try! String(contentsOf: URL(fileURLWithPath: "input/day2.txt"), encoding: .utf8)

enum MatchResult: String, Equatable {
    case defeat = "X"
    case draw = "Y"
    case win = "Z"
    
    func reachedBy(with move: Move) -> Move {
        switch (self, move) {
        case (.defeat, .paper), (.draw, .rock), (.win, .scissors):
            return .rock
        case (.defeat, .scissors), (.draw, .paper), (.win, .rock):
            return .paper
        case (.defeat, .rock), (.draw, .scissors), (.win, .paper):
            return .scissors
        }
    }
    
    func points() -> Int {
        switch self {
        case .defeat:
            return 0
        case .draw:
            return 3
        case .win:
            return 6
        }
    }
}

enum Move: Equatable {
    case rock
    case paper
    case scissors
    
    static func with(_ string: String) -> Self {
        switch string {
        case "A", "X":
            return .rock
        case "B", "Y":
            return .paper
        case "C", "Z":
            return .scissors
        default:
            fatalError()
        }
    }
    
    func score() -> Int {
        switch self {
        case .rock: return 1
        case .paper: return 2
        case .scissors: return 3
        }
    }
    
    func points(against move2: Move) -> Int {
        switch (move2, self) {
        case (.rock, .paper), (.paper, .scissors), (.scissors, .rock):
            return MatchResult.win.points()
        case (.rock, .rock), (.paper, .paper), (.scissors, .scissors):
            return MatchResult.draw.points()
        default:
            return MatchResult.defeat.points()
        }
    }
}

func solve1() -> Int {
    input.components(separatedBy: "\n")
        .filter { !$0.isEmpty }
        .map { $0.components(separatedBy: " ").map(Move.with) }
        .map { $0[1].score() + $0[1].points(against: $0[0])  }
        .reduce(0, +)
}

func solve2() -> Int {
    input.components(separatedBy: "\n")
        .filter { !$0.isEmpty }
        .map { line -> (Move, MatchResult) in
            let comps = line.components(separatedBy: " ")
            return (Move.with(comps[0]), MatchResult(rawValue: comps[1])!)
        }
        .map { $0.1.points() + $0.1.reachedBy(with: $0.0).score() }
        .reduce(0, +)
}

let start = CFAbsoluteTimeGetCurrent()

print(solve2())

let diff = CFAbsoluteTimeGetCurrent() - start
print("\(#function) Took \(diff) seconds")
