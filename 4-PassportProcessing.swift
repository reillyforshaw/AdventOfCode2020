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

protocol ValidationType {
    associatedtype T

    func validate(_ value: T) -> Bool
}

struct Validation<T> : ValidationType {
    var _validate: (T) -> Bool

    init(_ validate: @escaping (T) -> Bool) {
        _validate = validate
    }

    func validate(_ value: T) -> Bool {
        _validate(value)
    }

    func and(_ other: Validation) -> Validation {
        .init() { value in
            _validate(value) && other.validate(value)
        }
    }

    func and(_ other: @escaping (T) -> Bool) -> Validation {
        and(.init(other))
    }

    static var always: Self { .init() { _ in true } }
}

struct AnyValidation : ValidationType {
    var _validate: (Any) -> Bool

    init<V, T>(_ validation: V) where V : ValidationType, V.T == T {
        _validate = { any in
            (any as? T).map { validation.validate($0) } ?? false
        }
    }

    func validate(_ value: Any) -> Bool {
        _validate(value)
    }
}

extension Validation {
    var typeErased: AnyValidation { AnyValidation(self) }
}

func passportIsValid(_ passport: [String : String], validations: [String : AnyValidation]) -> Bool {
    for (field, validation) in validations {
        guard passport[field].map({ validation.validate($0) }) ?? false else {
            return false
        }
    }
    return true
}

func countOfValidPassports(in passports: [[String : String]], validations: [String : AnyValidation]) -> Int {
    var validPassportCount = 0

    for passport in passports {
        if passportIsValid(passport, validations: validations) {
            validPassportCount += 1
        }
    }

    return validPassportCount
}

func part1() {
    let fieldRequiredValidation = Validation<String>.always.typeErased
    let validations: [String : AnyValidation] = [
        "byr" : fieldRequiredValidation,
        "iyr" : fieldRequiredValidation,
        "eyr" : fieldRequiredValidation,
        "hgt" : fieldRequiredValidation,
        "hcl" : fieldRequiredValidation,
        "ecl" : fieldRequiredValidation,
        "pid" : fieldRequiredValidation,
    ]

    let validPassportCount = countOfValidPassports(in: passports, validations: validations)

    print("Part 1: Number of valid passports: \(validPassportCount)")
}
part1()

func part2() {
    func numberOfDigitsValidation(_ numberOfDigits: Int) -> Validation<String> {
        .init() { $0.count == numberOfDigits }
    }

    func integerInRange(_ range: ClosedRange<Int>) -> Validation<String> {
        .init() { Int($0).map { range.contains($0) } ?? false }
    }

    let heightValidation = Validation<String> {
        guard $0.count > 2 else { return false }

        let unitStartIndex = $0.index($0.endIndex, offsetBy: -2)

        guard let magnitude = Int($0[$0.startIndex ..< unitStartIndex]) else { return false }
        let unit = $0[unitStartIndex ..< $0.endIndex]

        switch unit {
        case "cm":
            return magnitude >= 150 && magnitude <= 193
        case "in":
            return magnitude >= 59 && magnitude <= 76
        default:
            return false
        }
    }

    let hairColorValidation = Validation<String> {
        guard $0.count == 7, $0.first! == "#" else { return false }

        let hex = $0[$0.index($0.startIndex, offsetBy: 1) ..< $0.endIndex]
        let allowedCharacters: Set<Character> = [ "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f" ] as Set<Character>

        for char in hex {
            guard allowedCharacters.contains(char) else {
                return false
            }
        }
        return true
    }

    let validEyeColors: Set<String> = [ "amb", "blu", "brn", "gry", "grn", "hzl", "oth" ]

    let validations: [String : AnyValidation] = [
        "byr" : numberOfDigitsValidation(4).and(integerInRange(1920...2002)).typeErased,
        "iyr" : numberOfDigitsValidation(4).and(integerInRange(2010...2020)).typeErased,
        "eyr" : numberOfDigitsValidation(4).and(integerInRange(2020...2030)).typeErased,
        "hgt" : heightValidation.typeErased,
        "hcl" : hairColorValidation.typeErased,
        "ecl" : Validation<String>({ validEyeColors.contains($0) }).typeErased,
        "pid" : numberOfDigitsValidation(9).and({ Int($0) != nil }).typeErased,
    ]
    let validPassportCount = countOfValidPassports(in: passports, validations: validations)

    print("Part 2: Number of valid passports: \(validPassportCount)")
}
part2()
