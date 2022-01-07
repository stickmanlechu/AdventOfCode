import Foundation

func loopSize(for pubKey: Int) -> Int {
    var initialValue = 1
    var lpSize = 0
    while initialValue != pubKey {
        lpSize += 1
        initialValue *= 7
        initialValue %= 20201227
    }
    return lpSize
}

func transform(subject: Int, loopSize: Int) -> Int {
    var initialValue = 1
    for _ in 1...loopSize {
        initialValue *= subject
        initialValue %= 20201227
    }
    return initialValue
}

let pubkeys = [1965712, 19072108]

let start = CFAbsoluteTimeGetCurrent()

print(transform(subject: pubkeys[0], loopSize: loopSize(for: pubkeys[1])))

let diff = CFAbsoluteTimeGetCurrent() - start
print("\(#function) Took \(diff) seconds")
