#!/usr/bin/swift

import Foundation

let root = URL(fileURLWithPath: (CommandLine.arguments[0] as NSString).deletingLastPathComponent)
let inputURL = URL(fileURLWithPath: "1-ReportRepair-Input", relativeTo: root)

guard
    let data = try? Data(contentsOf: inputURL),
    let input = String(data: data, encoding: .utf8)?.split(separator: "\n").map({ Int($0)! })
else {
    fatalError("Couldn't parse input")
}

var seen: Set<Int> = []
var result: Int?

for record in input {
    let other = 2020 - record
    if seen.contains(other) {
        result = record * (other)
        break
    }
    seen.insert(record)
}

if let result = result {
    print("Result: \(result)")
} else {
    print("Result not found")
}
