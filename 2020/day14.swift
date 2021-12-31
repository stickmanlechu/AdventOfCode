import Foundation

struct Mask {
    var toSub: [UInt] = []
    var toOr: [UInt] = []
    var toX: [UInt] = []
    
    static func parse(_ str: String) -> Mask {
        var mask = Mask()
        var stack = str.replacingOccurrences(of: "mask = ", with: "")
        let max = stack.count
        while let element = stack.popLast() {
            let index = (max - stack.count - 1)
            let int = UInt(1 << index)
            switch element {
            case "1": mask.toOr.append(int)
            case "0": mask.toSub.append(int)
            default: mask.toX.append(int)
            }
        }
        return mask
    }
    
    func process(_ int: UInt) -> UInt {
        var toRet = int
        toOr.forEach { toRet |= $0 }
        toSub.forEach {
            guard toRet & $0 == $0 else { return }
            toRet -= $0
        }
        return toRet
    }
    
    func process(address: UInt) -> [UInt] {
        var processed = address
        toOr.forEach {
            if processed & $0 == 0 {
                processed += $0
            }
        }
        var addresses = [processed]
        toX.forEach { int in
            addresses.append(contentsOf: addresses.map {
                return ($0 & int == 0) ? $0 + int : $0 - int
            })
        }
        return addresses
    }
}

func addressAndValue(from string: String) -> (ad: UInt, val: UInt) {
    let ints = string
        .replacingOccurrences(of: "mem[", with: "")
        .replacingOccurrences(of: "] = ", with: ":")
        .components(separatedBy: ":")
        .map { UInt($0)! }
    return (ad: ints[0], val: ints[1])
}

func solve1(_ input: String) -> UInt {
    var registers = [UInt: UInt]()
    var currentMask: Mask! = nil
    for line in input.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: "\n") {
        guard !line.starts(with: "mask") else {
            currentMask = .parse(line)
            continue
        }
        let adAndVal = addressAndValue(from: line)
        registers[adAndVal.ad] = currentMask.process(adAndVal.val)
    }
    return registers.values.reduce(0, +)
}

func solve2(_ input: String) -> UInt {
    var registers = [UInt: UInt]()
    var currentMask: Mask! = nil
    for line in input.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: "\n") {
        guard !line.starts(with: "mask") else {
            currentMask = .parse(line)
            continue
        }
        let adAndVal = addressAndValue(from: line)
        currentMask.process(address: adAndVal.ad).forEach { ad in
            registers[ad] = adAndVal.val
        }
    }
    return registers.values.reduce(0, +)
}

let input = try! String(contentsOf: URL(fileURLWithPath: "input/day14.txt"), encoding: .utf8)

let start = CFAbsoluteTimeGetCurrent()

//print(solve1(input))
print(solve2(input))

let diff = CFAbsoluteTimeGetCurrent() - start
print("\(#function) Took \(diff) seconds")
