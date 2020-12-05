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

protocol PasswordRule {
    init(int1: Int, int2: Int, character: Character)

    func isPasswordValid(_ password: String) -> Bool
}

struct CharacterOccurrenceRangePasswordRule : PasswordRule {
    var range: Range<Int>
    var character: Character

    init(int1: Int, int2: Int, character: Character) {
        self.range = .init(int1...int2)
        self.character = character
    }

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

struct CharacterPositionPasswordRule : PasswordRule {
    var position1: Int
    var position2: Int
    var character: Character

    init(int1: Int, int2: Int, character: Character) {
        self.position1 = int1 - 1
        self.position2 = int2 - 1
        self.character = character
    }

    func isPasswordValid(_ password: String) -> Bool {
        let p1: Bool
        if position1 < password.count {
            p1 = password[password.index(password.startIndex, offsetBy: position1)] == character
        } else {
            p1 = false
        }

        let p2: Bool
        if position2 < password.count {
            p2 = password[password.index(password.startIndex, offsetBy: position2)] == character
        } else {
            p2 = false
        }

        return (p1 && !p2) || (!p1 && p2)
    }
}

extension String {
    subscript(_ range: NSRange) -> Substring {
        let low = index(startIndex, offsetBy: range.location)
        let high = index(startIndex, offsetBy: range.location + range.length)

        return self[low..<high]
    }
}

struct Parser {
    static let pattern = "([0-9]+)-([0-9]+) ([a-z]): ([a-z]+)"
    static let regex = try! NSRegularExpression(pattern: pattern, options: [])

    func parseLine(_ line: String) -> (int1: Int, int2: Int, character: Character, password: String) {
        let match = Parser.regex.firstMatch(in: line, options: [], range: NSMakeRange(0, line.count))!

        let int1Range = match.range(at: 1)
        let int1 = Int(line[int1Range])!

        let int2Range = match.range(at: 2)
        let int2 = Int(line[int2Range])!

        let characterRange = match.range(at: 3)
        let character = line[characterRange].first!

        let passwordRange = match.range(at: 4)
        let password = String(line[passwordRange])

        return (
            int1: int1,
            int2: int2,
            character: character,
            password: password
        )
    }
}

var rangeRuleCount = 0
var positionRuleCount = 0
let parser = Parser()

for line in input {
    let (int1, int2, character, password) = parser.parseLine(line)

    let rangeRule = CharacterOccurrenceRangePasswordRule(int1: int1, int2: int2, character: character)
    if rangeRule.isPasswordValid(password) {
        rangeRuleCount += 1
    }

    let positionRule = CharacterPositionPasswordRule(int1: int1, int2: int2, character: character)
    if positionRule.isPasswordValid(password) {
        positionRuleCount += 1
    }
}

print("Range rule valid password count: \(rangeRuleCount)")
print("Position rule valid password count: \(positionRuleCount)")
