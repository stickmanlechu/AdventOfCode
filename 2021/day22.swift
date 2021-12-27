import Foundation

extension String {
    var range: ClosedRange<Int> {
        let ends = replacingOccurrences(of: "..", with: ".")
            .split(separator: ".")
            .map(String.init)
            .map { Int($0)! }
        return ends[0]...ends[1]
    }
}

struct Slice {
    let range: ClosedRange<Int>
    let cutOut: Bool
}

extension ClosedRange where Element == Int {
    func contains(_ another: Self) -> Bool {
        contains(another.lowerBound) && contains(another.upperBound)
    }
    
    func intersects(_ another: Self) -> Bool {
        contains(another.lowerBound) || contains(another.upperBound) || another.contains(self)
    }
    
    func slice(_ another: Self) -> [Slice] {
        guard !another.contains(self) else {
            return [.init(range: self, cutOut: true)]
        }
        if another.lowerBound <= lowerBound {
            return [.init(range: lowerBound...another.upperBound, cutOut: true), .init(range: (another.upperBound + 1)...upperBound, cutOut: false)]
        }
        if another.upperBound >= upperBound {
            return [.init(range: lowerBound...(another.lowerBound - 1), cutOut: false), .init(range: another.lowerBound...upperBound, cutOut: true)]
        }
        return [
            .init(range: lowerBound...(another.lowerBound - 1), cutOut: false),
            .init(range: another, cutOut: true),
            .init(range: (another.upperBound + 1)...upperBound, cutOut: false)
        ]
    }
}

struct Figure3D: Hashable, CustomStringConvertible {
    let x: ClosedRange<Int>
    let y: ClosedRange<Int>
    let z: ClosedRange<Int>
    
    func subtracting(_ another: Figure3D) -> [Figure3D] {
        guard !another.contains(self) else { return [] }
        guard intersects(another) else { return [self] }
        let xs = x.slice(another.x)
        let ys = y.slice(another.y)
        let zs = z.slice(another.z)
        let figures = xs.flatMap { xSlice in ys.flatMap { ySlice in zs.compactMap { zSlice -> Figure3D? in
            guard !(xSlice.cutOut && ySlice.cutOut && zSlice.cutOut) else { return nil }
            return Figure3D(x: xSlice.range, y: ySlice.range, z: zSlice.range)
        } } }
        return figures
    }
    
    func contains(_ another: Figure3D) -> Bool {
        x.contains(another.x) && y.contains(another.y) && z.contains(another.z)
    }
    
    func intersects(_ another: Figure3D) -> Bool {
        x.intersects(another.x) && y.intersects(another.y) && z.intersects(another.z)
    }
    
    var pointsInside: Int {
        x.count * y.count * z.count
    }
    
    var description: String {
        "x: \(x) y: \(y) z: \(z)"
    }
}

enum Action {
    case on(Figure3D)
    case off(Figure3D)
}

func parse(_ input: String, max: Int? = nil) -> [Action] {
    input
        .split(separator: "\n")
        .map(String.init)
        .compactMap { line -> Action? in
            let isOn = line.starts(with: "on")
            let simplified = line.replacingOccurrences(of: "((on|off) )|x=|y=|z=", with: "", options: .regularExpression)
            let comps = simplified
                .split(separator: ",")
                .map(String.init)
                .compactMap { str -> ClosedRange<Int>? in
                    let range = str.range
                    guard let max = max else { return range }
                    guard abs(range.lowerBound) <= max && abs(range.upperBound) <= max else { return nil }
                    return range
                }
            guard comps.count == 3 else { return nil }
            let figure = Figure3D(x: comps[0], y: comps[1], z: comps[2])
            return isOn ? Action.on(figure) : .off(figure)
        }
}

func solve(_ actions: [Action]) -> Int {
    actions.reduce(into: [Figure3D]()) { partialResult, action in
        switch action {
        case .on(let figure):
            partialResult = partialResult.flatMap { $0.subtracting(figure) } + [figure]
        case .off(let figure):
            partialResult = partialResult.flatMap { $0.subtracting(figure) }
        }
    }.map(\.pointsInside).reduce(0, +)
}

let input = (try! String(contentsOf: URL(fileURLWithPath: "input/day22.txt"), encoding: .utf8)).trimmingCharacters(in: .whitespacesAndNewlines)
//let actions = parse(input, max: 50)
let actions = parse(input)

let start = CFAbsoluteTimeGetCurrent()

print(solve(actions))

let diff = CFAbsoluteTimeGetCurrent() - start
print("\(#function) Took \(diff) seconds")
