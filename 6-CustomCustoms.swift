#!/usr/bin/swift

import Foundation
import Darwin

let scriptPath = CommandLine.arguments[0] as NSString

let root = URL(fileURLWithPath: (scriptPath).deletingLastPathComponent)
let inputURL = URL(fileURLWithPath: "6-CustomCustoms-Input", relativeTo: root)

struct Group {
    var raw: String

    var questionsAnsweredYes: Set<Character> {
        raw.replacingOccurrences(of: "\n", with: "").reduce(into: []) {
            $0.insert($1)
        }
    }

    var questionsAllAnsweredYes: Set<Character> {
        let sets = raw.split(separator: "\n").map { Set($0) }
        return sets[1...].reduce(into: sets[0]) {
            $0.formIntersection($1)
        }
    }
}

guard
    let data = try? Data(contentsOf: inputURL),
    let groups = String(data: data, encoding: .utf8)?.components(separatedBy: "\n\n").map({ Group(raw: $0) })
else {
    print("Couldn't parse input")
    exit(1)
}

func part1() {
    let sum = groups.reduce(0) { $0 + $1.questionsAnsweredYes.count }

    print("Part 1: Checksum: \(sum).")
}
part1()

func part2() {
    let sum = groups.reduce(0) { $0 + $1.questionsAllAnsweredYes.count }

    print("Part 2: Checksum: \(sum)")
}
part2()
