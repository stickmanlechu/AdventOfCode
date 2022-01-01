import Foundation

func solve(_ input: String, maxRound: Int = 2020) -> Int {
    let numbers = input.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: ",").map { Int($0)! }
    var round = 1
    var numberRound = [Int: Int]()
    var lastNumber: Int!
    for number in numbers {
        numberRound[number] = round
        lastNumber = number
        round += 1
    }
    var newNumber = true
    var prevRound: Int!
    while round <= maxRound {
        lastNumber = newNumber ? 0 : ((round - 1) - prevRound)
        newNumber = numberRound[lastNumber] == nil
        if !newNumber { prevRound = numberRound[lastNumber]! }
        numberRound[lastNumber] = round
        round += 1
    }
    return lastNumber
}

let start = CFAbsoluteTimeGetCurrent()

print(solve("0,20,7,16,1,18,15", maxRound: 30000000))

let diff = CFAbsoluteTimeGetCurrent() - start
print("\(#function) Took \(diff) seconds")
