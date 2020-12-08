#!/usr/bin/swift

import Foundation
import Darwin

let scriptPath = CommandLine.arguments[0] as NSString

let root = URL(fileURLWithPath: (scriptPath).deletingLastPathComponent)
let inputURL = URL(fileURLWithPath: "5-BinaryBoarding-Input", relativeTo: root)

guard
    let data = try? Data(contentsOf: inputURL),
    let input = String(data: data, encoding: .utf8)?.split(separator: "\n")
else {
    print("Couldn't parse input")
    exit(1)
}

struct Seat {
    var row: Int
    var column: Int
    var id: Int { row * 8 + column }
}

func parseSeatSpecifier<S : StringProtocol>(_ specifier: S) -> Seat {
    guard specifier.count == 10 else {
        fatalError("Expected 10 characters in seat specified, got \(specifier.count) (\(specifier))")
    }

    let columnStartIndex = specifier.index(specifier.endIndex, offsetBy: -3)

    func parseRow() -> Int {
        (0..<7).reduce(0) {
            let lsb = specifier[specifier.index(specifier.startIndex, offsetBy: $1)] == "B" ? 1 : 0

            return $0 << 1 + lsb

        }
    }

    let rowRange = specifier.startIndex..<specifier.index(specifier.startIndex, offsetBy: 7)
    let row = (specifier[rowRange]).reduce(0) {
        $0 << 1 + ($1 == "B" ? 1 : 0)

    }
    let columnRange = columnStartIndex..<specifier.endIndex
    let column = (specifier[columnRange]).reduce(0) {
        $0 << 1 + ($1 == "R" ? 1 : 0)
    }

    return Seat(row: row, column: column)
}

func part1() {
    var seatWithLargestId: Seat = Seat(row: -1, column: -1)

    for specifier in input {
        let seat = parseSeatSpecifier(specifier)
        if seat.id > seatWithLargestId.id {
            seatWithLargestId = seat
        }
    }
    print("Part 1: Largest Id: \(seatWithLargestId.id) (row: \(seatWithLargestId.row), column: \(seatWithLargestId.column)).")
}
part1()

func part2() {
    let seatsById: [Int : Seat] = input.map(parseSeatSpecifier).reduce(into: [:]) {
        $0[$1.id] = $1
    }

    var foundOccupiedSection = false
    for id in 0..<(128 * 8) {
        if let _ = seatsById[id] {
            foundOccupiedSection = true
        } else {
            if foundOccupiedSection {
                print("Part 2: My seat id is: \(id).")
                return
            }
        }
    }
    print("Part 2: Couldn't find seat.")
}
part2()
