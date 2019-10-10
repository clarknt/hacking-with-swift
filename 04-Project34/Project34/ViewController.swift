//
//  ViewController.swift
//  Project34
//
//  Created by clarknt on 2019-10-07.
//  Copyright © 2019 clarknt. All rights reserved.
//

import GameplayKit
import UIKit

// challenge 2
enum Difficulty: Int {
    case easy = 1
    case medium = 3
    case hard = 5
}

// challenge 2
protocol PlayerSelectionDelegate: class {
    func setPlayers(player1Type: PlayerType, player2Type: PlayerType)
}

class ViewController: UIViewController, PlayerSelectionDelegate {

    @IBOutlet var columnButtons: [UIButton]!

    var placedChips = [[UIView]]()
    var board: Board!

    var strategist: GKMinmaxStrategist!

    // challenge 2
    var difficulty = Difficulty.medium

    override func viewDidLoad() {
        super.viewDidLoad()
        for _ in 0 ..< Board.width {
            placedChips.append([UIView]())
        }

        strategist = GKMinmaxStrategist()
        // challenge 2
        //strategist.maxLookAheadDepth = difficulty.rawValue
        // nil: return the best move
        strategist.randomSource = nil
        // or: random within the best moves
        //strategist.randomSource = GKARC4RandomSource()

        resetBoard()

        // challenge 2
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "New game", style: .plain, target: self, action: #selector(newGameTapped))

        // bonus: styling
        let baseColor = UIColor.systemBlue
        view.backgroundColor = baseColor.darkerColor()
        for button in columnButtons {
            button.backgroundColor = baseColor
        }
        // async to let the view draw and scale first
        DispatchQueue.main.async { [weak self] in
            self?.drawBackground(color: baseColor.lighterColor())
        }
    }

    // challenge 2
    @objc func newGameTapped() {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "NewGame") as? NewGameViewController {
            vc.playerSelectionDelegate = self
            if let player1 = board.players?[0] as? Player {
                vc.currentPlayer1 = player1.playerType
            }
            if let player2 = board.players?[1] as? Player {
                vc.currentPlayer2 = player2.playerType
            }
            vc.modalPresentationStyle = .popover
            vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem

            self.present(vc, animated: true)
        }
    }

    func resetBoard() {
        board = Board()
        strategist.gameModel = board

        updateUI()

        for i in 0 ..< placedChips.count {
            for chip in placedChips[i] {
                chip.removeFromSuperview()
            }

            placedChips[i].removeAll(keepingCapacity: true)
        }
    }

    func columnForAIMove() -> Int? {
        var chipsNumber = 0
        for col in placedChips {
            chipsNumber += col.count
        }

        // make first move random to avoid AI playing always the same moves
        if chipsNumber <= 2 {
            return Int.random(in: 0 ..< Board.width)
        }

        if let aiMove = strategist.bestMove(for: board.currentPlayer) as? Move {
            return aiMove.column
        }

        return nil
    }

    func makeAIMove(in column: Int) {
        columnButtons.forEach { $0.isEnabled = true }
        navigationItem.leftBarButtonItem = nil

        if let row = board.nextEmptySlot(in: column) {
            board.add(chip: board.currentPlayer.chip, in: column)
            addChip(inColumn: column, row: row, color: board.currentPlayer.color)

            continueGame()
        }
    }

    func startAIMove() {
        columnButtons.forEach { $0.isEnabled = false }

        let spinner = UIActivityIndicatorView(style: .gray)
        spinner.startAnimating()
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: spinner)


        DispatchQueue.global().async { [unowned self] in
            let strategistTime = CFAbsoluteTimeGetCurrent()
            guard let column = self.columnForAIMove() else { return }
            let delta = CFAbsoluteTimeGetCurrent() - strategistTime

            // let a moment elapse before playing
            let aiTimeCeiling: Double
            if self.board.currentPlayer.opponent.playerType == .human {
                aiTimeCeiling = 1.0
            }
            else {
                aiTimeCeiling = 0.5
            }
            let delay = aiTimeCeiling - delta

            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.makeAIMove(in: column)
            }
        }
    }

    // bonus: background circles
    func drawBackground(color: UIColor) {
        for col in 0 ..< Board.width {
            for row in 0 ..< Board.height {
                let button = columnButtons[col]
                let size = getSize(forButton: button)
                let rect = CGRect(x: 0, y: 0, width: size, height: size)

                let newChip = UIView()
                newChip.frame = rect
                newChip.isUserInteractionEnabled = false
                newChip.backgroundColor = color
                newChip.layer.cornerRadius = size / 2
                newChip.center = positionForChip(inColumn: col, row: row)
                view.addSubview(newChip)
            }
        }
    }

    func addChip(inColumn column: Int, row: Int, color: UIColor) {
        let button = columnButtons[column]
        let size = getSize(forButton: button)
        let rect = CGRect(x: 0, y: 0, width: size, height: size)

        if placedChips[column].count < row + 1 {
            // challenge 3
            let newChip = ChipView(color: color)
            newChip.frame = rect
            newChip.isUserInteractionEnabled = false
            newChip.center = positionForChip(inColumn: column, row: row)
            newChip.transform = CGAffineTransform(translationX: 0, y: -800)
            view.addSubview(newChip)

            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {
                newChip.transform = CGAffineTransform.identity
            })

            placedChips[column].append(newChip)
        }
    }

    func getSize(forButton button: UIButton) -> CGFloat {
        return min(button.frame.width, button.frame.height / CGFloat(Board.height))
    }

    func positionForChip(inColumn column: Int, row: Int) -> CGPoint {
        let button = columnButtons[column]
        let size = getSize(forButton: button)

        let xOffset = button.frame.midX
        var yOffset = button.frame.maxY - size / 2
        yOffset -= size * CGFloat(row)

        return CGPoint(x: xOffset, y: yOffset)
    }

    func updateUI() {
        title = "\(board.currentPlayer.name)'s turn"

        switch board.currentPlayer.playerType {
        case .human:
            break
        case .easyAI:
            strategist.maxLookAheadDepth = Difficulty.easy.rawValue
            startAIMove()
        case .mediumAI:
            strategist.maxLookAheadDepth = Difficulty.medium.rawValue
            startAIMove()
        case .hardAI:
            strategist.maxLookAheadDepth = Difficulty.hard.rawValue
            startAIMove()
        }
    }

    func continueGame() {
        var gameOverTitle: String? = nil

        if board.isWin(for: board.currentPlayer) {
            gameOverTitle = "\(board.currentPlayer.name) wins"
        }
        else if board.isFull() {
            gameOverTitle = "Draw"
        }

        if gameOverTitle != nil {
            let alert = UIAlertController(title: gameOverTitle, message: nil, preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "Play again", style: .default) { [unowned self] (action) in
                self.resetBoard()
            }
            alert.addAction(alertAction)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(alert, animated: true)

            return
        }

        board.currentPlayer = board.currentPlayer.opponent
        updateUI()
    }

    @IBAction func makeMove(_ sender: UIButton) {
        let column = sender.tag

        if let row = board.nextEmptySlot(in: column) {
            board.add(chip: board.currentPlayer.chip, in: column)
            addChip(inColumn: column, row: row, color: board.currentPlayer.color)
            continueGame()
        }
    }

    // challenge 2
    func setPlayers(player1Type: PlayerType, player2Type: PlayerType) {
        if let player1 = board.players?[0] as? Player {
            player1.playerType = player1Type
        }
        if let player2 = board.players?[1] as? Player {
            player2.playerType = player2Type
        }

        resetBoard()
    }
}

