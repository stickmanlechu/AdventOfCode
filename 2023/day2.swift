import Foundation

let input = try! String(contentsOf: URL(fileURLWithPath: "input/day2.txt"), encoding: .utf8)

struct Game: Hashable {
    let id: Int
    let rounds: [Round]
    
    static func parse(_ line: String) -> Game? {
        guard !line.isEmpty else { return nil }
        let components = line.components(separatedBy: ": ")
        let no = Int(components[0].replacingOccurrences(of: "Game ", with: ""))!
        return Game(id: no, rounds: components[1].components(separatedBy: "; ").compactMap(Round.parse))
    }
    
    func isPossible(red: Int, blue: Int, green: Int) -> Bool {
        rounds.first(where: { !$0.isPossible(red: red, blue: blue, green: green) }) == nil
    }
    
    func min() -> Int {
        let red = rounds.map(\.red).max()!
        let blue = rounds.map(\.blue).max()!
        let green = rounds.map(\.green).max()!
        return red * blue * green
    }
}

struct Round: Hashable {
    let red: Int
    let blue: Int
    let green: Int
    
    static func parse(_ line: String) -> Round {
        var vals = (red: 0, blue:0, green: 0)
        for comp in line.components(separatedBy: ", ") {
            let components = comp.components(separatedBy: " ")
            let val = Int(components[0])!
            switch components[1] {
            case "blue": vals.blue = val
            case "red": vals.red = val
            case "green": vals.green = val
            default: fatalError()
            }
        }
        return .init(red: vals.red, blue: vals.blue, green: vals.green)
    }
    
    func isPossible(red: Int, blue: Int, green: Int) -> Bool {
        self.red <= red && self.blue <= blue && self.green <= green
    }
}

func solve1() -> Int {
    input
        .components(separatedBy: "\n")
        .compactMap(Game.parse)
        .filter { $0.isPossible(red: 12, blue: 14, green: 13) }
        .map(\.id)
        .reduce(0, +)
}

func solve2() -> Int {
    input
        .components(separatedBy: "\n")
        .compactMap(Game.parse)
        .map { $0.min() }
        .reduce(0, +)
}

let start = CFAbsoluteTimeGetCurrent()

//print(solve1())
print(solve2())

let diff = CFAbsoluteTimeGetCurrent() - start
print("\(#function) Took \(diff) seconds")
