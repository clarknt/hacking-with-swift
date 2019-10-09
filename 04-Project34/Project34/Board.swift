//
//  Board.swift
//  Project34
//
//  Created by clarknt on 2019-10-07.
//  Copyright © 2019 clarknt. All rights reserved.
//

import GameplayKit
import UIKit

enum ChipColor: Int {
    case none = 0
    case red
    case yellow
}

class Board: NSObject {
    static var width = 7
    static var height = 6

    var slots = [ChipColor]()

    var currentPlayer: Player

    override init() {
        for _ in 0 ..< Board.width * Board.height {
            slots.append(.none)
        }

        currentPlayer = Player.allPlayers[0]
    }

    func chip(inColumn column: Int, row: Int) -> ChipColor {
        return slots[row + column * Board.height]
    }

    func set(chip: ChipColor, in column: Int, row: Int) {
        slots[row + column * Board.height] = chip
    }

    func nextEmptySlot(in column: Int) -> Int? {
        for row in 0 ..< Board.height {
            if chip(inColumn: column, row: row) == .none {
                return row
            }
        }

        return nil
    }

    func canMove(in column: Int) -> Bool {
        return nextEmptySlot(in: column) != nil
    }

    func add(chip: ChipColor, in column: Int) {
        if let row = nextEmptySlot(in: column) {
            set(chip: chip, in: column, row: row)
        }
    }

    func isFull() -> Bool {
        for column in 0 ..< Board.width {
            if canMove(in: column) {
                return false
            }
        }

        return true
    }

    func squaresMatch(initialChip: ChipColor, row: Int, col: Int, moveX: Int, moveY: Int) -> Bool {
        // no need to go further for cases that end up outside the board
        if row + (moveY * 3) < 0 { return false }
        if row + (moveY * 3) >= Board.height { return false }
        if col + (moveX * 3) < 0 { return false }
        if col + (moveX * 3) >= Board.width { return false }

        // check every square
        if chip(inColumn: col, row: row) != initialChip { return false }
        if chip(inColumn: col + moveX, row: row + moveY) != initialChip { return false }
        if chip(inColumn: col + (moveX * 2), row: row + (moveY * 2)) != initialChip { return false }
        if chip(inColumn: col + (moveX * 3), row: row + (moveY * 3)) != initialChip { return false }

        return true
    }
}

extension Board: GKGameModel {
    // these methods are used by GameplayKit to simulate next moves and evaluate
    // their outcome, using copies of the Board to apply changes incrementally

    // used by GameplayKit but also by our game engine
    func isWin(for player: GKGameModelPlayer) -> Bool {
        let chip = (player as! Player).chip

        for row in 0 ..< Board.height {
            for col in 0 ..< Board.width {
                // horizontal
                if squaresMatch(initialChip: chip, row: row, col: col, moveX: 1, moveY: 0) {
                    return true
                }
                // vertical
                if squaresMatch(initialChip: chip, row: row, col: col, moveX: 0, moveY: 1) {
                    return true
                }
                // diagonal 1
                if squaresMatch(initialChip: chip, row: row, col: col, moveX: 1, moveY: 1) {
                    return true
                }
                // diagonal 2
                if squaresMatch(initialChip: chip, row: row, col: col, moveX: 1, moveY: -1) {
                    return true
                }
            }
        }

        return false
    }

    func copy(with zone: NSZone? = nil) -> Any {
        let copy = Board()
        copy.setGameModel(self)
        return copy
    }

    func setGameModel(_ gameModel: GKGameModel) {
        if let board = gameModel as? Board {
            slots = board.slots
            currentPlayer = board.currentPlayer
        }
    }

    func gameModelUpdates(for player: GKGameModelPlayer) -> [GKGameModelUpdate]? {
        guard let playerObject = player as? Player else { return nil }

        // no more moves available
        if isWin(for: playerObject) || isWin(for: playerObject.opponent) {
            return nil
        }

        // find every possible move
        var moves = [Move]()
        for column in 0 ..< Board.width {
            if canMove(in: column) {
                moves.append(Move(column: column))
            }
        }

        return moves
    }

    func apply(_ gameModelUpdate: GKGameModelUpdate) {
        if let move = gameModelUpdate as? Move {
            add(chip: currentPlayer.chip, in: move.column)
            currentPlayer = currentPlayer.opponent
        }
    }

    func score(for player: GKGameModelPlayer) -> Int {
        guard let playerObject = player as? Player else { return 0 }

        // basic heuristic: 1000 points for a win, -1000 for a loss, 0 for neither
        if isWin(for: playerObject) {
            return 1000
        }
        else if isWin(for: playerObject.opponent) {
            return -1000
        }

        return 0
    }

    var players: [GKGameModelPlayer]? {
        return Player.allPlayers
    }

    var activePlayer: GKGameModelPlayer? {
        return currentPlayer
    }
}
