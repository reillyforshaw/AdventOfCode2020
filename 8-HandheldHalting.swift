#!/usr/bin/swift

import Foundation
import Darwin

let scriptPath = CommandLine.arguments[0] as NSString

let root = URL(fileURLWithPath: (scriptPath).deletingLastPathComponent)
let inputURL = URL(fileURLWithPath: "8-HandheldHalting-Input", relativeTo: root)

guard
    let data = try? Data(contentsOf: inputURL),
    let input = String(data: data, encoding: .utf8)?.split(separator: "\n")
else {
    print("Couldn't parse input")
    exit(1)
}

enum Instruction {
    case acc(Int)
    case jmp(Int)
    case nop(Int)

    init(_ raw: String) {
        let components = raw.split(separator: " ")
        guard components.count == 2 else {
            fatalError("Expected 2 components in instruction, got \(components.count) (\(raw))")
        }

        guard let arg = Int(components[1]) else {
            fatalError("Invalid argument: \(components[1])")
        }

        switch components[0] {
        case "acc":
            self = .acc(arg)
        case "jmp":
            self = .jmp(arg)
        case "nop":
            self = .nop(arg)
        default:
            fatalError("Unknown instruction: \(components[0])")
        }
    }
}

struct Runtime {
    struct Globals : Hashable {
        var acc: Int
    }

    enum Error : Swift.Error {
        case infiniteLoopDetected(pc: Int, globals: Globals)
        case fatal(pc: Int)
    }

    var program: [Instruction]

    init(program: [Instruction]) {
        self.program = program
    }

    func run() throws -> Globals {
        struct State : Hashable {
            var pc: Int
        }
        var seenStates: Set<State> = []

        var pc = 0
        var globals = Globals(acc: 0)

        while pc < program.endIndex {
            let state = State(pc: pc)
            guard !seenStates.contains(state) else {
                throw Error.infiniteLoopDetected(pc: pc, globals: globals)
            }
            seenStates.insert(state)

            switch program[pc] {
            case let .acc(arg):
                globals.acc += arg
                pc = program.index(pc, offsetBy: 1)
            case let .jmp(arg):
                let newPc = program.index(pc, offsetBy: arg)
                if newPc < 0 {
                    throw Error.fatal(pc: pc)
                }
                pc = newPc
            case .nop:
                pc = program.index(pc, offsetBy: 1)
            }
        }
        return globals
    }
}

let instructions = input.map { Instruction(String($0)) }

func part1() {
    let runtime = Runtime(program: instructions)
    do {
        _ = try runtime.run()
        print("Part 1: No runtime error detected.")
    } catch let Runtime.Error.infiniteLoopDetected(pc: pc, globals: globals) {
        print("Part 1: Accumlator state before infinite loop: \(globals.acc) (pc: \(pc))")
    } catch {
        fatalError("Part 1: Unexpected error: \(error).")
    }
}
part1()

func part2() {
    func modifyProgram(_ program: inout [Instruction], afterOffset offset: Int) -> Int? {
        for idx in offset..<program.count {
            switch program[idx] {
            case let .jmp(arg):
                program[idx] = .nop(arg)
                return idx
            case let .nop(arg):
                program[idx] = .jmp(arg)
                return idx
            default:
                continue
            }
        }
        return nil
    }

    var nextOffset = 0
    while nextOffset < instructions.count {
        var copy = instructions
        guard let modifiedIndex = modifyProgram(&copy, afterOffset: nextOffset) else {
            print("Part 2: No more modifications.")
            return
        }

        guard let result = try? Runtime(program: copy).run() else {
            nextOffset = modifiedIndex + 1
            continue
        }

        print("Part 2: Program finished after changing instruction \(modifiedIndex) from \(instructions[modifiedIndex]) to \(copy[modifiedIndex]) with final accumulator value: \(result.acc).")
        break
    }
}
part2()
