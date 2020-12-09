#!/usr/bin/swift

import Foundation
import Darwin

let scriptPath = CommandLine.arguments[0] as NSString

let root = URL(fileURLWithPath: (scriptPath).deletingLastPathComponent)
let inputURL = URL(fileURLWithPath: "7-HandyHaversacks-Input", relativeTo: root)

guard
    let data = try? Data(contentsOf: inputURL),
    let input = String(data: data, encoding: .utf8)?.split(separator: "\n")
else {
    print("Couldn't parse input")
    exit(1)
}

typealias Contents = [(count: Int, bag: String)]
func parseRule<S : StringProtocol>(_ rule: S) -> (bag: String, contents: Contents) {
    let rootComponents = rule[rule.startIndex..<rule.index(rule.endIndex, offsetBy: -1)].components(separatedBy: " bags contain ")

    guard rootComponents.count == 2 else {
        fatalError("Expected 2 root components, got \(rootComponents.count) (\(rootComponents))")
    }

    let bag = rootComponents[0]

    let contents: [(count: Int, bag: String)]
    if rootComponents[1] == "no other bags" {
        contents = []
    } else {
        contents = rootComponents[1].components(separatedBy: ", ").map {
            let contentComponents = $0.split(separator: " ", maxSplits: 1)
            guard contentComponents.count == 2 else {
                fatalError("Expected 2 content components, got \(contentComponents.count) (\(contentComponents))")
            }

            let count = Int(contentComponents[0])!
            let bag = contentComponents[1].dropLast(count == 1 ? 4 : 5) // " bag" vs " bags"

            return (count: count, bag: String(bag))
        }
    }

    return (bag: bag, contents: contents)
}

let graph: [String : Contents] = input.reduce(into: [:]) {
    let (bag, contents) = parseRule($1)
    $0[bag] = contents
}

func part1() {
    var cache: [String : Bool] = [:]
    func canBag(_ parent: String, eventuallyContain bag: String) -> Bool {
        if let cached = cache[parent] { return cached }

        var canContain = false
        for child in graph[parent]! {
            if child.bag == bag {
                canContain = true
            } else {
                canContain = canBag(child.bag, eventuallyContain: bag)
            }

            if canContain {
                break
            }
        }
        cache[parent] = canContain

        return canContain
    }

    let count = graph.keys.reduce(0) { $0 + (canBag($1, eventuallyContain: "shiny gold") ? 1 : 0) }

    print("Part 1: Number of bags that can contain shiny gold bags: \(count)")
}
part1()

func part2() {
    func numberOfBagsContainedIn(_ parent: String) -> Int {
        return graph[parent]!.reduce(0) {
            $0 + $1.count * (1 + numberOfBagsContainedIn($1.bag))
        }
    }

    let count = numberOfBagsContainedIn("shiny gold")

    print("Part 2: Shiny gold bags contain \(count) other bags.")
}
part2()
