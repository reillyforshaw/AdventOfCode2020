#!/usr/bin/swift

import Foundation
import Darwin

let scriptPath = CommandLine.arguments[0] as NSString

let root = URL(fileURLWithPath: (scriptPath).deletingLastPathComponent)
let inputURL = URL(fileURLWithPath: "3-TobogganTrajectory-Input", relativeTo: root)

guard
    let data = try? Data(contentsOf: inputURL),
    let input = String(data: data, encoding: .utf8)?.split(separator: "\n").map(String.init)
else {
    print("Couldn't parse input")
    exit(1)
}

struct Grid {
    struct Position {
        var row: Int
        var column: Int
    }

    struct Slope {
        var rise: Int
        var run: Int
    }

    let input: [String]

    var origin: Position { .init(row: 0, column: 0) }

    subscript(_ position: Position) -> Character {
        let rowPattern = input[position.row]
        let columnIndex = rowPattern.index(
            rowPattern.startIndex,
            offsetBy: position.column % rowPattern.count
        )
        return rowPattern[columnIndex]
    }

    func positionAfterSteppingFrom(position previousPosition: Position, withSlope slope: Slope) -> Position? {
        let row = previousPosition.row + slope.rise
        guard row < input.count else {
            return nil
        }

        return .init(row: row, column: previousPosition.column + slope.run)
    }
}
let grid = Grid(input: input)

let slope = Grid.Slope(rise: 1, run: 3)
var position = grid.origin

var treeCount = 0
while let nextPosition = grid.positionAfterSteppingFrom(position: position, withSlope: slope) {
    position = nextPosition

    if grid[position] == "#" {
        treeCount += 1
    }
}

print("Tree count with slope \(slope.rise):\(slope.run): \(treeCount)")
