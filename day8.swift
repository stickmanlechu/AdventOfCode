import Foundation

extension Set {
    func contains(_ set: Set<Element>) -> Bool {
        intersection(set) == set
    }
}

struct Sequence {
    let signals: [Set<Character>]
    let output: [Set<Character>]
    
    init(_ str: String) {
        let comps = str.split(separator: "|")
        
        self.signals = comps[0]
            .split(separator: " ")
            .map(String.init)
            .map(Set.init)
        
        self.output = comps[1]
            .split(separator: " ")
            .map(String.init)
            .map(Set.init)
    }
    
    var outputLenghts: [Int] {
        output.map { $0.count }
    }
    
    func translateOutput() -> Int {
        let one = signals.first(where: { $0.count == 2 })!
        let four = signals.first(where: { $0.count == 4 })!
        let seven = signals.first(where: { $0.count == 3 })!
        let eight = signals.first(where: { $0.count == 7 })!
        let three = signals.filter { $0.count == 5 }.first(where: { $0.contains(one) && $0.contains(seven) })!
        let six = signals.filter { $0.count == 6 }.first(where: { !$0.contains(one) && !$0.contains(seven) })!
        let two = signals.filter { $0.count == 5 && $0 != three }.first(where: { $0.contains(eight.subtracting(six)) })!
        let five = signals.filter { $0.count == 5 }.first(where: { $0 != two && $0 != three })!
        let zero = signals.filter { $0.count == 6 }.first(where: { $0.contains(eight.subtracting(five)) })!
        let nine = signals.filter { $0.count == 6 }.first(where: { $0 != zero && $0 != six })!
        let mapping = [zero: "0", one: "1", two: "2", three: "3", four: "4", five: "5", six: "6", seven: "7", eight: "8", nine: "9"]
        return Int(output.compactMap { mapping[$0] }.joined())!
    }
}

func count1s4s7sAnd8s(sequences: [Sequence]) -> Int {
    let uniqueLenghts = Set([2, 4, 3, 7])
    return sequences.reduce(0) { partialResult, sequence in
        partialResult + sequence.outputLenghts.filter { uniqueLenghts.contains($0) }.count
    }
}

let input = (try! String(contentsOf: URL(fileURLWithPath: "input/day8.txt"), encoding: .utf8)).trimmingCharacters(in: .whitespacesAndNewlines)

let sequences = input.split(separator: "\n")
    .map(String.init)
    .map(Sequence.init)

let start = CFAbsoluteTimeGetCurrent()

//print(count1s4s7sAnd8s(sequences: sequences))
print(sequences.reduce(0, { $0 + $1.translateOutput() }))

let diff = CFAbsoluteTimeGetCurrent() - start
print("\(#function) Took \(diff) seconds")

