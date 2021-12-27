import Foundation

let charBitMapping: [Character: [Int]] = [
    "0": [0, 0, 0, 0],
    "1": [0, 0, 0, 1],
    "2": [0, 0, 1, 0],
    "3": [0, 0, 1, 1],
    "4": [0, 1, 0, 0],
    "5": [0, 1, 0, 1],
    "6": [0, 1, 1, 0],
    "7": [0, 1, 1, 1],
    "8": [1, 0, 0, 0],
    "9": [1, 0, 0, 1],
    "A": [1, 0, 1, 0],
    "B": [1, 0, 1, 1],
    "C": [1, 1, 0, 0],
    "D": [1, 1, 0, 1],
    "E": [1, 1, 1, 0],
    "F": [1, 1, 1, 1]
]

protocol Packet {
    var version: Int { get }
    var value: Int { get }
}

struct LiteralPacket: Packet {
    let version: Int
    let value: Int
}

struct OperatorPacket: Packet {
    enum OperatorType: Int {
        case sum = 0
        case product = 1
        case min = 2
        case max = 3
        case greaterThan = 5
        case lessThan = 6
        case equalTo = 7
    }
    
    let version: Int
    let operatorType: OperatorType
    let subpackets: [Packet]
    
    var value: Int {
        switch operatorType {
        case .sum:
            return subpackets.map(\.value).reduce(0, +)
        case .product:
            return subpackets.map(\.value).reduce(1, *)
        case .min:
            return subpackets.map(\.value).min()!
        case .max:
            return subpackets.map(\.value).max()!
        case .greaterThan:
            return subpackets.first!.value > subpackets.last!.value ? 1 : 0
        case .lessThan:
            return subpackets.first!.value < subpackets.last!.value ? 1 : 0
        case .equalTo:
            return subpackets.first!.value == subpackets.last!.value ? 1 : 0
        }
    }
}

func toInt<T: Sequence>(_ bytes: T) -> Int where T.Element == Int {
    bytes.reversed().enumerated().reduce(0) { result, byte in result + (1 << byte.offset) * byte.element }
}

func packet(from bits: [Int]) -> Packet {
    var index = 0
    return readPacket(from: bits, index: &index)
}

func readPacket(from bits: [Int], index: inout Int) -> Packet {
    let version = toInt(bits[index...(index + 2)])
    let typeId = toInt(bits[(index + 3)...(index + 5)])
    index += 6
    switch typeId {
    case 4: return LiteralPacket(version: version, value: readValue(from: bits, index: &index))
    default: return readOperationPacket(from: bits, index: &index, version: version, typeId: typeId)
    }
}

func readOperationPacket(from bits: [Int], index: inout Int, version: Int, typeId: Int) -> Packet {
    switch bits[index] {
    case 0:
        index += 1
        return readBitLengthRestrictedPacket(from: bits, index: &index, version: version, typeId: typeId)
    case 1:
        index += 1
        return readCountRestrictedPacket(from: bits, index: &index, version: version, typeId: typeId)
    default: fatalError("Unsupported length type")
    }
}

func readBitLengthRestrictedPacket(from bits: [Int], index: inout Int, version: Int, typeId: Int) -> Packet {
    let maxBits = toInt(bits[index...(index + 14)])
    index += 15
    let endIndex = index + maxBits
    var packets: [Packet] = []
    while index < endIndex {
        packets.append(readPacket(from: bits, index: &index))
    }
    return OperatorPacket(version: version, operatorType: .init(rawValue: typeId)!, subpackets: packets)
}

func readCountRestrictedPacket(from bits: [Int], index: inout Int, version: Int, typeId: Int) -> Packet {
    let count = toInt(bits[index...(index + 10)])
    index += 11
    let packets = (0..<count).reduce(into: [Packet]()) { partialResult, _ in
        return partialResult.append(readPacket(from: bits, index: &index))
    }
    return OperatorPacket(version: version, operatorType: .init(rawValue: typeId)!, subpackets: packets)
}

func readValue(from bits: [Int], index: inout Int) -> Int {
    var bitsRead = 6 // taking version and type id into consideration
    var valueBits = [Int]()
    while(true) {
        let part = bits[index...(index + 4)]
        valueBits.append(contentsOf: part.dropFirst())
        bitsRead += 5
        index += 5
        guard part.first! == 1 else { break }
    }
    return toInt(valueBits)
}

func versionSum(for packet: Packet) -> Int {
    guard let packet = packet as? OperatorPacket else { return packet.version }
    return packet.version + packet.subpackets.reduce(0, { $0 + versionSum(for: $1) })
}

let input = (try! String(contentsOf: URL(fileURLWithPath: "input/day16.txt"), encoding: .utf8)).trimmingCharacters(in: .whitespacesAndNewlines)
let bits = input.flatMap { charBitMapping[$0]! }

let start = CFAbsoluteTimeGetCurrent()

print(versionSum(for: packet(from: bits)))
//print(packet(from: bits).value)

let diff = CFAbsoluteTimeGetCurrent() - start
print("\(#function) Took \(diff) seconds")


