import Foundation

func parse(_ input: String) -> [[String: String]] {
    var passports = [[String: String]]()
    var currentPassport = [String: String]()
    for line in input.components(separatedBy: "\n") {
        guard line.count > 0 else {
            passports.append(currentPassport)
            currentPassport = [:]
            continue
        }
        line.components(separatedBy: " ").forEach { pair in
            let comps = pair.components(separatedBy: ":")
            currentPassport[comps[0]] = comps[1]
        }
    }
    passports.append(currentPassport)
    return passports
}

func isValid(passportKey: String, data: String) -> Bool {
    switch passportKey {
    case "byr": return (1920...2002).contains(Int(data)!)
    case "iyr": return (2010...2020).contains(Int(data)!)
    case "eyr": return (2020...2030).contains(Int(data)!)
    case "hgt" where data.hasSuffix("cm"):
        return (150...193).contains(Int(data.replacingOccurrences(of: "cm", with: ""))!)
    case "hgt":
        return (59...76).contains(Int(data.replacingOccurrences(of: "in", with: ""))!)
    case "hcl":
        return data.replacingOccurrences(of: "^#[0-9a-f]{6}$", with: "", options: .regularExpression).isEmpty
    case "ecl":
        return ["amb", "blu", "brn", "gry", "grn", "hzl", "oth"].contains(data)
    case "pid":
        return data.replacingOccurrences(of: "^[0-9]{9}$", with: "", options: .regularExpression).isEmpty
    case "cid": return true
    default: fatalError()
    }
}

extension Dictionary where Key == String {
    var keySet: Set<String> {
        return Set(keys)
    }
}

let required = Set(["byr", "iyr", "eyr", "hgt", "hcl", "ecl", "pid"])

func solve1(_ passports: [[String: String]]) -> Int {
    passports.reduce(0) { partialResult, passport in
        partialResult + (passport.keySet.intersection(required) == required ? 1 : 0)
    }
}

func solve2(_ passports: [[String: String]]) -> Int {
    passports.reduce(0) { partialResult, passport in
        guard passport.keySet.intersection(required) == required else {
            return partialResult
        }
        guard passport.allSatisfy({ isValid(passportKey: $0, data: $1) }) else {
            return partialResult
        }
        return partialResult + 1
    }
}

let input = try! String(contentsOf: URL(fileURLWithPath: "input/day4.txt"), encoding: .utf8)

let start = CFAbsoluteTimeGetCurrent()

//print(solve1(parse(input)))
print(solve2(parse(input)))

let diff = CFAbsoluteTimeGetCurrent() - start
print("\(#function) Took \(diff) seconds")
