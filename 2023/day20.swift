import Foundation

let input = try! String(contentsOf: URL(fileURLWithPath: "input/day20.txt"), encoding: .utf8).trimmingCharacters(in: .whitespacesAndNewlines)

protocol Module: Hashable {
    var targets: [String] { get }
}

struct PlainModule: Module, Hashable {
    let targets: [String]
}

struct FlipFlop: Module, Hashable {
    let targets: [String]
    var isOn: Bool
}

struct Conjunction: Module, Hashable {
    let name: String
    let targets: [String]
    var inputs: [String: Int] = [:]
}

struct Operation: Hashable {
    let moduleName: String
    let signal: Int
    let source: String
}

func solve(minNumberOfCycles: Int) -> Int {
    var modules: [String: any Module] = [:]
    var allTargets = [String: [String]]()
    for line in input.components(separatedBy: .newlines).filter({ !$0.isEmpty }) {
        let comps = line.replacingOccurrences(of: "&|%", with: "", options: .regularExpression).components(separatedBy: " -> ")
        let targets = comps[1].components(separatedBy: ", ")
        for t in targets {
            allTargets[t] = allTargets[t, default: []] + [comps[0]]
        }
        if line.starts(with: "&") {
            modules[comps[0]] = Conjunction(name: comps[0], targets: targets)
        } else if line.starts(with: "%") {
            modules[comps[0]] = FlipFlop(targets: targets, isOn: false)
        } else {
            modules[comps[0]] = PlainModule(targets: targets)
        }
    }
    for module in modules.values {
        guard var conjunction = module as? Conjunction else { continue }
        for target in allTargets[conjunction.name, default: []] {
            conjunction.inputs[target] = 0
        }
        modules[conjunction.name] = conjunction
    }
    var firstTimes: [String: Int] = [:]
    var cycles: [String: Int] = [:]
    
    var signals = [0, 0]
    for i in 1...minNumberOfCycles {
        var operations = [Operation(moduleName: "broadcaster", signal: 0, source: "button")]
        while !operations.isEmpty {
            let operation = operations.removeFirst()
            signals[operation.signal] += 1
            switch modules[operation.moduleName] {
            case .none: continue
            case let module as PlainModule:
                operations.append(contentsOf: module.targets.map { Operation(moduleName: $0, signal: operation.signal, source: operation.moduleName) })
            case var module as FlipFlop:
                guard operation.signal == 0 else { continue }
                let newSignal = module.isOn ? 0 : 1
                module.isOn.toggle()
                modules[operation.moduleName] = module
                operations.append(contentsOf: module.targets.map { Operation(moduleName: $0, signal: newSignal, source: operation.moduleName) })
            case var module as Conjunction:
                module.inputs[operation.source] = operation.signal
                modules[operation.moduleName] = module
                let newSignal = module.inputs.values.allSatisfy({ $0 == 1 }) ? 0 : 1
                operations.append(contentsOf: module.targets.map { Operation(moduleName: $0, signal: newSignal, source: operation.moduleName) })
                guard module.targets == ["rx"] && operation.signal == 1 else { continue }
                guard let ft = firstTimes[operation.source] else {
                    firstTimes[operation.source] = i
                    continue
                }
                let cycle = i - ft
                firstTimes[operation.source] = i
                cycles[operation.source] = cycle
                if cycles.count == module.inputs.count {
                    return cycles.values.reduce(1, *)
                }
            default: fatalError()
            }
        }
    }
    return signals[0] * signals[1]
}

func solve1() -> Int {
    return solve(minNumberOfCycles: 1000)
}

func solve2() -> Int {
    return solve(minNumberOfCycles: 1000000)
}

let start = CFAbsoluteTimeGetCurrent()

print(solve1())
print(solve2())

let diff = CFAbsoluteTimeGetCurrent() - start
print("\(#function) Took \(diff) seconds")
