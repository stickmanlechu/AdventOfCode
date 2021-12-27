import Foundation

func possibleHorizontalVelocities(thatEndUpWithin closedRange: ClosedRange<Int>) -> [Int: [Int]] {
    var result: [Int: [Int]] = [:]
    for initialVelocity in 1...xRange.upperBound {
        var position = 0
        var steps = 0
        while position <= closedRange.upperBound && steps <= initialVelocity {
            position += initialVelocity - steps
            steps += 1
            guard closedRange.contains(position) else { continue }
            if initialVelocity == steps - 1 {
                ((steps - 1)...2000).forEach { result[$0, default: []].append(initialVelocity) }
            } else {
                result[steps, default: []].append(initialVelocity)
            }
        }
    }
    return result
}

func maxVerticalPosition(toEndUpIn closedRange: ClosedRange<Int>, stepsAllowed: Set<Int>) -> Int {
    var startingVelocity = 0
    var maxHeightPossible = 0
    while true {
        var position = 0
        var currentVelocity = startingVelocity
        var currentMaxHeight = 0
        var step = 0
        while true {
            position += currentVelocity
            currentVelocity -= 1
            currentMaxHeight = max(position, currentMaxHeight)
            if closedRange.contains(position) && stepsAllowed.contains(step) {
                maxHeightPossible = max(maxHeightPossible, currentMaxHeight)
            }
            if closedRange.lowerBound > position {
                break
            }
            step += 1
        }
        startingVelocity += 1
        guard startingVelocity < 130 else { break }
    }
    return maxHeightPossible
}

struct Velocity: Hashable {
    let x: Int
    let y: Int
}

func numberOfUniqueStartingVelocities(toEndUpIn closedRange: ClosedRange<Int>, stepsHorizontalVelocityMapping: [Int: [Int]]) -> Int {
    var startingVelocity = -250
    var velocities = Set<Velocity>()
    while true {
        var position = 0
        var currentVelocity = startingVelocity
        var step = 0
        while true {
            position += currentVelocity
            currentVelocity -= 1
            if closedRange.contains(position), let horizontalVelocities = stepsHorizontalVelocityMapping[step + 1] {
                horizontalVelocities.forEach { x in
                    velocities.insert(.init(x: x, y: startingVelocity))
                }
            }
            if closedRange.lowerBound > position {
                break
            }
            step += 1
        }
        startingVelocity += 1
        guard startingVelocity < 250 else { break }
    }
    return velocities.count
}

let input = (try! String(contentsOf: URL(fileURLWithPath: "input/day17.txt"), encoding: .utf8)).trimmingCharacters(in: .whitespacesAndNewlines)
let parsedInput = input
    .replacingOccurrences(of: "target area: x=", with: "")
    .replacingOccurrences(of: ", y=", with: ";")
    .replacingOccurrences(of: "..", with: ":")
    .split(separator: ";")
    .map(String.init)
    .map { str -> ClosedRange<Int> in
        let comps = str.split(separator: ":").map(String.init).map { Int($0)! }
        return comps.first!...comps.last!
    }
let xRange = parsedInput.first!
let yRange = parsedInput.last!

let start = CFAbsoluteTimeGetCurrent()

let stepsMap = possibleHorizontalVelocities(thatEndUpWithin: xRange)
//print(maxVerticalPosition(toEndUpIn: yRange, stepsAllowed: Set(stepsMap.keys)))
print(numberOfUniqueStartingVelocities(toEndUpIn: yRange, stepsHorizontalVelocityMapping: stepsMap))


let diff = CFAbsoluteTimeGetCurrent() - start
print("\(#function) Took \(diff) seconds")
