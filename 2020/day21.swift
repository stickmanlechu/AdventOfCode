import Foundation

func parse(_ input: String) -> ([String], [String: Set<String>]) {
    var allergenIngredient = [String: Set<String>]()
    var allIngredients = [String]()
    input
        .trimmingCharacters(in: .whitespacesAndNewlines)
        .replacingOccurrences(of: " (contains ", with: ":")
        .replacingOccurrences(of: ")", with: "")
        .components(separatedBy: "\n")
        .forEach {
            let comps = $0.components(separatedBy: ":")
            let ingredients = Set(comps[0].components(separatedBy: " "))
            allIngredients.append(contentsOf: ingredients)
            let allergens = comps[1].components(separatedBy: ", ")
            allergens.forEach {
                allergenIngredient[$0, default: ingredients].formIntersection(ingredients)
            }
        }
    return (allIngredients, allergenIngredient)
}

func solve1(_ input: String) -> Int {
    let parsed = parse(input)
    let allergic = parsed.1.values.reduce(into: Set<String>()) { $0.formUnion($1) }
    let notAllergic = Set(parsed.0).subtracting(allergic)
    return notAllergic.reduce(0) { partialResult, ingredient in
        partialResult + parsed.0.filter({ $0 == ingredient }).count
    }
}

func solve2(_ input: String) -> String {
    let parsed = parse(input)
    var mapping = parsed.1
    var stack = mapping.keys.filter({ mapping[$0]!.count == 1 })
    while let key = stack.popLast() {
        let toRemove = mapping[key]!
        for k in mapping.keys where k != key && mapping[k]!.count > 1 {
            mapping[k]?.subtract(toRemove)
            if mapping[k]!.count == 1 {
                stack.append(k)
            }
        }
    }
    return mapping.sorted(by: { $0.key < $1.key }).compactMap(\.value.first).joined(separator: ",")
}

let input = try! String(contentsOf: URL(fileURLWithPath: "input/day21.txt"), encoding: .utf8)

let start = CFAbsoluteTimeGetCurrent()

print(solve2(input))

let diff = CFAbsoluteTimeGetCurrent() - start
print("\(#function) Took \(diff) seconds")
