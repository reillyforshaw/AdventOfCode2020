#!/usr/bin/swift

import Foundation
import Darwin

let scriptPath = CommandLine.arguments[0] as NSString

let root = URL(fileURLWithPath: (scriptPath).deletingLastPathComponent)
let inputURL = URL(fileURLWithPath: "4-PassportProcessing-Input", relativeTo: root)

guard
    let data = try? Data(contentsOf: inputURL),
    let input = String(data: data, encoding: .utf8)?.components(separatedBy: "\n\n")
else {
    print("Couldn't parse input")
    exit(1)
}

let passports: [[String : String]] = input.map {
    $0.replacingOccurrences(of: "\n", with: " ")
}.reduce(into: []) {
    var passport: [String : String] = [:]

    $1.split(separator: " ").forEach {
        let components = $0.split(separator: ":")
        passport[String(components[0])] = String(components[1])
    }

    $0.append(passport)
}

func isPassportValid(_ passport: [String : String], requiredFields: Set<String>) -> Bool {
    for requiredField in requiredFields {
        guard let _ = passport[requiredField] else {
            return false
        }
    }
    return true
}

func part1() {
    var validPassportCount = 0

    let requiredFields: Set<String> = [
        "byr",
        "iyr",
        "eyr",
        "hgt",
        "hcl",
        "ecl",
        "pid",
    ]
    for passport in passports {
        if isPassportValid(passport, requiredFields: requiredFields) {
            validPassportCount += 1
        }
    }

    print("Part 1: Number of valid passports: \(validPassportCount)")
}
part1()
