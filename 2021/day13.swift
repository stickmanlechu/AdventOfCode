import Foundation

enum Fold {
    case left(value: Int)
    case up(value: Int)
}

func createPaper(from inputRows: [String]) -> [[Int]] {
    let dots = inputRows
        .filter { !$0.starts(with: "fold") }
        .map { $0.split(separator: ",") }
        .map {
            (Int($0[1])!, Int($0[0])!)
        }

    let maxRow = dots
        .map(\.0)
        .max()!
    let maxCol = dots
        .map(\.1)
        .max()!

    var paper = (0...maxRow).map { row in
        (0...maxCol).map { _ in 0 }
    }
    for dot in dots {
        paper[dot.0][dot.1] = 1
    }
    return paper
}

func extractFoldInstructions(from inputRows: [String]) -> [Fold] {
    inputRows
        .filter { $0.starts(with: "fold") }
        .map { $0.replacingOccurrences(of: "fold along ", with: "") }
        .map { $0.split(separator: "=") }
        .map { comps -> Fold in
            switch comps[0] {
            case "x": return .left(value: Int(comps[1])!)
            case "y": return .up(value: Int(comps[1])!)
            default: fatalError()
            }
        }
}

func maximum(_ x: Int, _ y: Int) -> Int {
    return x > y ? x : y
}

extension Array where Element == [Int] {
    func folded(accordingTo instruction: Fold) -> Self {
        switch instruction {
        case .left(let col):
            return foldedLeft(along: col)
        case .up(let row):
            return foldedUp(along: row)
        }
    }
    
    func foldedUp(along row: Int) -> Self {
        (0..<row)
            .map { r -> [Int] in
                (0..<self[row].count).map { c -> Int in
                    maximum(self[r][c], self[count - 1 - r][c])
                }
            }
    }
    
    func foldedLeft(along col: Int) -> Self {
        map { row in
            (0..<col).map { c in
                maximum(row[c], row[row.count - 1 - c])
            }
        }
    }
    
    func pretty() -> String {
        map { row in
            row.map { $0 == 0 ? " " : "#" }.joined()
        }.joined(separator: "\n")
    }
}

let input = (try! String(contentsOf: URL(fileURLWithPath: "input/day13.txt"), encoding: .utf8)).trimmingCharacters(in: .whitespacesAndNewlines)
let inputRows = input
    .split(separator: "\n")
    .map(String.init)

let foldInstructions = extractFoldInstructions(from: inputRows)
let paper = createPaper(from: inputRows)

let start = CFAbsoluteTimeGetCurrent()

//print(paper.folded(accordingTo: foldInstructions[0]).flatMap { $0 }.reduce(0, +))
print(foldInstructions.reduce(paper) { partialResult, instruction in partialResult.folded(accordingTo: instruction)  }.pretty())

let diff = CFAbsoluteTimeGetCurrent() - start
print("\(#function) Took \(diff) seconds")
