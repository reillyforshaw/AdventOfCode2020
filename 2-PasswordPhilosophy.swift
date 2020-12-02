#!/usr/bin/swift

import Foundation
import Darwin

let scriptPath = CommandLine.arguments[0] as NSString

let root = URL(fileURLWithPath: (scriptPath).deletingLastPathComponent)
let inputURL = URL(fileURLWithPath: "2-PasswordPhilosophy-Input", relativeTo: root)

guard
    let data = try? Data(contentsOf: inputURL),
    let input = String(data: data, encoding: .utf8)?.split(separator: "\n").map(String.init)
else {
    print("Couldn't parse input")
    exit(1)
}

struct PasswordRule {
    var range: Range<Int>
    var character: Character

    func isPasswordValid(_ password: String) -> Bool {
        var count = 0
        for char in password {
            if char == character {
                count += 1
            }
        }

        return range.contains(count)
    }
}

extension String {
    subscript(_ range: NSRange) -> Substring {
        let low = index(startIndex, offsetBy: range.location)
        let high = index(startIndex, offsetBy: range.location + range.length)

        return self[low..<high]
    }
}

let pattern = "([0-9]+)-([0-9]+) ([a-z]): ([a-z]+)"
let regex = try! NSRegularExpression(pattern: pattern, options: [])

func parseLine(_ line: String) -> (rule: PasswordRule, password: String) {
    let match = regex.firstMatch(in: line, options: [], range: NSMakeRange(0, line.count))!

    let minRange = match.range(at: 1)
    let min = Int(line[minRange])!

    let maxRange = match.range(at: 2)
    let max = Int(line[maxRange])!

    let characterRange = match.range(at: 3)
    let character = line[characterRange].first!

    let passwordRange = match.range(at: 4)
    let password = String(line[passwordRange])

    return (
        rule: .init(range: .init(min...max), character: character),
        password: password
    )
}

var count = 0
for line in input {
    let (rule, password) = parseLine(line)

    if rule.isPasswordValid(password) {
        count += 1
    }
}

print("Valid password count: \(count)")
