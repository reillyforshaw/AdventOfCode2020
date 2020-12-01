#!/usr/bin/swift

import Foundation

guard CommandLine.arguments.count == 3 else {
    fatalError("Must provide target and number of records")
}

guard let target = Int(CommandLine.arguments[1]) else {
    fatalError("Target must be an integer")
}

guard let numberOfRecords = Int(CommandLine.arguments[2]), numberOfRecords > 0 else {
    fatalError("Number of records must be an integer greater than 0")
}

let root = URL(fileURLWithPath: (CommandLine.arguments[0] as NSString).deletingLastPathComponent)
let inputURL = URL(fileURLWithPath: "1-ReportRepair-Input", relativeTo: root)

guard
    let data = try? Data(contentsOf: inputURL),
    let input = String(data: data, encoding: .utf8)?.split(separator: "\n").map({ Int($0)! })
else {
    fatalError("Couldn't parse input")
}

/*
 * Complexity:
 * numberOfRecords == 1: O(n)
 * numberOfRecords  > 1: O(n^(numberOfRecords - 1))
 */
func findRecords(summingTo target: Int, numberOfRecords: Int, in input: Array<Int>.SubSequence) -> [Int]? {
    if numberOfRecords == 1 {
        // Trivial case, for completeness
        if input.contains(target) {
            return [target]
        } else {
            return nil
        }
    } else if numberOfRecords == 2 {
        // Base case
        var seen: Set<Int> = []

        for record in input {
            let other = target - record
            if seen.contains(other) {
                return [other, record]
            }
            seen.insert(record)
        }
        return nil
    } else {
        // Recursion
        for record in input {
            if let result = findRecords(summingTo: target - record, numberOfRecords: numberOfRecords - 1, in: input.dropFirst()) {
                return [record] + result
            }
        }
        return nil
    }
}

if let result = findRecords(summingTo: target, numberOfRecords: numberOfRecords, in: input[...]) {
    print("Result: \(result) => \(result.reduce(1, *))")
} else {
    print("Result not found")
}
