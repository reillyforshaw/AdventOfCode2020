#!/usr/bin/swift

import Foundation
import Darwin

let scriptPath = CommandLine.arguments[0] as NSString

let root = URL(fileURLWithPath: (scriptPath).deletingLastPathComponent)
let inputURL = URL(fileURLWithPath: "9-EncodingError-Input", relativeTo: root)

guard
    let data = try? Data(contentsOf: inputURL),
    let input = String(data: data, encoding: .utf8)?.split(separator: "\n")
else {
    print("Couldn't parse input")
    exit(1)
}

let numbers = input.map { Int($0)! }

func isNumberValid(at index: Int, in numbers: [Int], preambleLength: Int) -> Bool {
    guard index >= preambleLength, index < numbers.count else { return false }

    let target = numbers[index]
    var seen: Set<Int> = []

    var found: Bool = false
    for idx in (index - preambleLength) ..< index {
        let number = numbers[idx]
        if seen.contains(target - number) {
            found = true
            break
        } else {
            seen.insert(number)
        }
    }

    return found
}

func part1() -> Int? {
    let preambleLength = 25
    for idx in preambleLength ..< numbers.count {
        if !isNumberValid(at: idx, in: numbers, preambleLength: preambleLength) {
            print("Part 1: First invalid number after peamble found at index: \(idx) (\(numbers[idx]))")

            return numbers[idx]
        }
    }

    print("Part 1: Invalid number not found.")
    return nil
}
let target = part1()

func part2() {
    guard let target = target else {
        print("Part 2: Part 1 unsuccessful, cannot run part 2.")
        return
    }

    for count in 2 ..< numbers.count {
        for i in numbers.indices {
            guard i + count < numbers.endIndex else {
                continue
            }

            let subsequence = numbers[i ..< (i + count)]
            if subsequence.reduce(0, +) == target {
                var min = Int.max
                var max = Int.min
                for num in subsequence {
                    if num < min { min = num }
                    if num > max { max = num }
                }
                let encryptionWeakness = min + max
                print("Part 2: encryption weakness: \(encryptionWeakness). (\(count) number sequence found at index \(i): \(subsequence))")
                return
            }
        }
    }
    print("Part 2: Encryption weakness not found.")
}
part2()
