// https://adventofcode.com/2021/day/4

import Foundation

let input = "17,58,52,49,72,33,55,73,27,69,88,80,9,7,59,98,63,42,84,37,87,28,97,66,79,77,61,48,83,5,94,26,70,12,51,82,99,45,22,64,10,78,13,18,15,39,8,30,68,65,40,21,6,86,90,29,60,4,38,3,43,93,44,50,41,96,20,62,19,91,23,36,47,92,76,31,67,11,0,56,95,85,35,16,2,14,75,53,1,57,81,46,71,54,24,74,89,32,25,34"

let boardsInput = try! String(contentsOf: URL(fileURLWithPath: "input/day4.txt"), encoding: .utf8)

final class BingoBoard {
    final class Field {
        var selected: Bool = false
        let value: Int
        
        init(_ value: Int) {
            self.value = value
        }
    }
    
    var rows: [[Field]]
    
    init(_ strings: [String]) {
        rows = strings.map { row in
            row
                .split(separator: " ")
                .map(String.init)
                .map { Field(Int($0)!) }
        }
    }
    
    func mark(num: Int) -> Bool {
        var marked = false
        for row in rows {
            for x in row where x.value == num {
                guard !x.selected else { continue }
                x.selected = true
                marked = true
            }
        }
        guard marked else { return false }
        return isBingo()
    }
    
    func isBingo() -> Bool {
        if let _ = rows.first(where: { fields in fields.allSatisfy(\.selected) }) {
            return true
        }
        let columns = (0..<rows.count).map { index in
            rows.map { $0[index] }
        }
        if let _ = columns.first(where: { fields in fields.allSatisfy(\.selected) }) {
            return true
        }
        return false
    }
    
    func score(lastNumber: Int) -> Int {
        rows.reduce(0) { partialResult, fields in
            partialResult + fields.reduce(0, { partialResult, field in
                return partialResult + (field.selected ? 0 : field.value)
            })
        } * lastNumber
    }
}

let numbers = input.split(separator: ",")
    .map(String.init)
    .map { Int($0)! }

let rows = boardsInput.split(separator: "\n")
    .map(String.init)

let boards = rows
    .indices
    .filter { ($0 + 1) % 5 == 0 }
    .map { BingoBoard(Array(rows[$0-4...$0])) }

func findFirst(boards: [BingoBoard], numbers: [Int]) -> Int {
    for number in numbers {
        for board in boards {
            guard board.mark(num: number) else { continue }
            return board.score(lastNumber: number)
        }
    }
    fatalError()
}

func findLast(boards: [BingoBoard], numbers: [Int]) -> Int {
    var currentBoards = boards
    for number in numbers {
        if currentBoards.count > 1 {
            currentBoards = currentBoards.filter({ !$0.mark(num: number) })
            continue
        }
        if currentBoards.count == 1 && currentBoards[0].mark(num: number) {
            return currentBoards[0].score(lastNumber: number)
        }
    }
    fatalError()
}

let start = CFAbsoluteTimeGetCurrent()

//print(findFirst(boards: boards, numbers: numbers))
print(findLast(boards: boards, numbers: numbers))

let diff = CFAbsoluteTimeGetCurrent() - start
print("\(#function) Took \(diff) seconds")
