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

    func positionAfterSteppingFrom(
        position previousPosition: Position,
        alongSlope slope: Slope
    ) -> Position? {
        let row = previousPosition.row + slope.rise
        guard row < input.count else {
            return nil
        }

        return .init(row: row, column: previousPosition.column + slope.run)
    }
}
let grid = Grid(input: input)


var position = grid.origin

func countTrees(
    in grid: Grid,
    startingFrom startPosition: Grid.Position,
    alongSlope slope: Grid.Slope
) -> Int {
    var position = startPosition

    var treeCount = 0
    while let nextPosition = grid.positionAfterSteppingFrom(position: position, alongSlope: slope) {
        position = nextPosition

        if grid[position] == "#" {
            treeCount += 1
        }
    }

    return treeCount
}

func part1() {
    let startPosition = grid.origin
    let slope = Grid.Slope(rise: 1, run: 3)
    let treeCount = countTrees(in: grid, startingFrom: startPosition, alongSlope: slope)

    print("Part 1: Tree count along slope \(slope.rise):\(slope.run): \(treeCount)")
}
part1()

func part2() {
    let slopes: [Grid.Slope] = [
        .init(rise: 1, run: 1),
        .init(rise: 1, run: 3),
        .init(rise: 1, run: 5),
        .init(rise: 1, run: 7),
        .init(rise: 2, run: 1),
    ]
    let treeCountAlongAllSlopes = slopes.reduce(1) {
        $0 * countTrees(in: grid, startingFrom: grid.origin, alongSlope: $1)
    }

    print("Part 2: Tree count along all slopes: \(treeCountAlongAllSlopes)")
}
part2()
