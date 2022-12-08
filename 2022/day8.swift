import Foundation

let input = try! String(contentsOf: URL(fileURLWithPath: "input/day8.txt"), encoding: .utf8)

let trees = input.components(separatedBy: "\n")
    .filter { !$0.isEmpty }
    .map { Array($0).map(String.init).compactMap(Int.init) }

func solve1() -> Int {
    var visibility = trees.map {
        $0.map { _ in false }
    }
    let colIndices = visibility[0].indices
    
    // top down
    for col in colIndices {
        var maxVal = -1
        for row in visibility.indices {
            visibility[row][col] = visibility[row][col] || maxVal < trees[row][col]
            maxVal = max(maxVal, trees[row][col])
        }
    }

    // bottom up
    for col in colIndices {
        var maxVal = -1
        for row in visibility.indices.reversed() {
            visibility[row][col] = visibility[row][col] || maxVal < trees[row][col]
            maxVal = max(maxVal, trees[row][col])
        }
    }

    // left to right
    for row in visibility.indices {
        var maxVal = -1
        for col in colIndices {
            visibility[row][col] = visibility[row][col] || maxVal < trees[row][col]
            maxVal = max(maxVal, trees[row][col])
        }
    }

    // right to left
    for row in visibility.indices {
        var maxVal = -1
        for col in colIndices.reversed() {
            visibility[row][col] = visibility[row][col] || maxVal < trees[row][col]
            maxVal = max(maxVal, trees[row][col])
        }
    }
    return visibility.flatMap { $0 }.filter { $0 }.count
}

func solve2() -> Int {
    var scenicScore = trees.map {
        $0.map { _ in 1 }
    }
    let colIndices = scenicScore[0].indices
    
    // top down
    for col in colIndices.dropFirst().dropLast() {
        for row in scenicScore.indices.dropFirst().dropLast() {
            //back
            var r = row - 1
            var s = 1
            while r > 0 && trees[r][col] < trees[row][col] {
                s += 1
                r -= 1
            }
            scenicScore[row][col] *= s
        }
    }
    
    // bottom up
    for col in colIndices.dropFirst().dropLast() {
        for row in scenicScore.indices.reversed().dropFirst().dropLast() {
            //back
            var r = row + 1
            var s = 1
            while r < scenicScore.endIndex - 1 && trees[r][col] < trees[row][col] {
                s += 1
                r += 1
            }
            scenicScore[row][col] *= s
        }
    }

    // left to right
    for row in scenicScore.indices.dropFirst().dropLast() {
        for col in colIndices.dropFirst().dropLast() {
            //back
            var c = col - 1
            var s = 1
            while c > 0 && trees[row][c] < trees[row][col] {
                s += 1
                c -= 1
            }
            scenicScore[row][col] *= s
        }
    }

    // right to left
    for row in scenicScore.indices.dropFirst().dropLast() {
        for col in colIndices.reversed().dropFirst().dropLast() {
            //back
            var c = col + 1
            var s = 1
            while c < colIndices.last! {
                s += 1
                guard trees[row][c] < trees[row][col] else { break }
                c += 1
            }
            scenicScore[row][col] *= s
        }
    }
    
    return scenicScore.flatMap { $0 }.max()!
}

let start = CFAbsoluteTimeGetCurrent()

print(solve1())

let diff = CFAbsoluteTimeGetCurrent() - start
print("\(#function) Took \(diff) seconds")
