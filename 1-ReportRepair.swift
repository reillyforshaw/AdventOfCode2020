#!/usr/bin/swift

import Foundation
import Darwin

let scriptPath = CommandLine.arguments[0] as NSString

guard CommandLine.arguments.count == 3 else {
    print("usage: \(scriptPath.lastPathComponent) target number_of_records")
    exit(1)
}

guard let target = Int(CommandLine.arguments[1]) else {
    print("Target must be an integer")
    exit(1)
}

guard let numberOfRecords = Int(CommandLine.arguments[2]), numberOfRecords > 0 else {
    print("Number of records must be an integer greater than 0")
    exit(1)
}

let root = URL(fileURLWithPath: (scriptPath).deletingLastPathComponent)
let inputURL = URL(fileURLWithPath: "1-ReportRepair-Input", relativeTo: root)

guard
    let data = try? Data(contentsOf: inputURL),
    let input = String(data: data, encoding: .utf8)?.split(separator: "\n").map({ Int($0)! })
else {
    print("Couldn't parse input")
    exit(1)
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
