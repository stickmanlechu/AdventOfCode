import Foundation

indirect enum Expression: Equatable {
    case number(Int)
    case add
    case mul
    case expressions([Expression])
    
    func eval1() -> Int {
        switch self {
        case .number(let val):
            return val
        case .expressions(let expressions) where expressions.count == 1:
            return expressions[0].eval1()
        case .expressions(let expressions):
            guard expressions[expressions.endIndex - 2] == .add else {
                return Expression.expressions(Array(expressions.dropLast(2))).eval1() * expressions.last!.eval1()
            }
            return Expression.expressions(Array(expressions.dropLast(2))).eval1() + expressions.last!.eval1()
        default:
            fatalError()
        }
    }
    
    func eval2() -> Int {
        switch self {
        case .expressions(let expressions):
            var stack: [Int] = []
            var index = 0
            while index < expressions.count {
                let expression = expressions[index]
                index += 1
                switch expression {
                case .number(let val):
                    stack.append(val)
                case .expressions:
                    stack.append(expression.eval2())
                case .add:
                    let previous = stack.popLast()!
                    stack.append(previous + expressions[index].eval2())
                    index += 1
                case .mul:
                    continue
                }
            }
            return stack.reduce(1, *)
        case .number(let val):
            return val
        default:
            fatalError()
        }
    }
}

func parse(_ line: String) -> Expression {
    var stack: [Any] = []
    for char in line {
        switch char {
        case "(":
            stack.append(char)
        case ")":
            var expressions = [Expression]()
            while let next = stack.popLast() {
                guard let next = next as? Expression else { break }
                expressions.insert(next, at: 0)
            }
            stack.append(Expression.expressions(expressions))
        case " ":
            continue
        case "+":
            stack.append(Expression.add)
        case "*":
            stack.append(Expression.mul)
        default:
            stack.append(Expression.number(Int(String(char))!))
        }
    }
    return Expression.expressions(stack as! [Expression])
}

func solve(_ input: String, addingPrecedence: Bool = false) -> Int {
    input
        .trimmingCharacters(in: .whitespacesAndNewlines)
        .components(separatedBy: "\n")
        .map { parse($0) }
        .map {
            addingPrecedence ? $0.eval2() : $0.eval1()
        }
        .reduce(0, +)
}

let input = try! String(contentsOf: URL(fileURLWithPath: "input/day18.txt"), encoding: .utf8)

let start = CFAbsoluteTimeGetCurrent()

print(solve(input, addingPrecedence: true))

let diff = CFAbsoluteTimeGetCurrent() - start
print("\(#function) Took \(diff) seconds")
