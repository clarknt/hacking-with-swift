//
//  NewGameViewController.swift
//  Project34
//
//  Created by clarknt on 2019-10-10.
//  Copyright © 2019 clarknt. All rights reserved.
//

import UIKit

// challenge 2
class NewGameViewController: UIViewController {

    @IBOutlet weak var player1TableView: UITableView!
    @IBOutlet weak var player2TableView: UITableView!

    @IBOutlet weak var toolbar: UIToolbar!

    var player1Choices = [PlayerType]()
    var player2Choices = [PlayerType]()

    weak var playerSelectionDelegate: PlayerSelectionDelegate?

    var currentPlayer1: PlayerType?
    var currentPlayer2: PlayerType?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Pick players"

        setPlayerChoices()

        player1TableView.dataSource = self
        player2TableView.dataSource = self

        setSelectedRows()

        let cancel = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(cancelTapped))
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let start = UIBarButtonItem(title: "Start", style: .done, target: self, action: #selector(startTapped))
        toolbar.items = [cancel, spacer, start]
    }

    func setPlayerChoices() {
        for player in PlayerType.allCases {
            player1Choices.append(player)
            player2Choices.append(player)
        }
    }

    func setSelectedRows() {
        let player1Row = currentPlayer1 != nil ? (player1Choices.firstIndex(of: currentPlayer1!) ?? 0) : 0
        let player1IndexPath = IndexPath(row: player1Row, section: 0)
        player1TableView.selectRow(at: player1IndexPath, animated: false, scrollPosition: .none)
        
        let player2Row = currentPlayer2 != nil ? (player2Choices.firstIndex(of: currentPlayer2!) ?? 0) : 0
        let player2IndexPath = IndexPath(row: player2Row, section: 0)
        player2TableView.selectRow(at: player2IndexPath, animated: false, scrollPosition: .none)
    }

    @objc func cancelTapped() {
        dismiss(animated: true)
    }

    @objc func startTapped() {
        let player1Index = player1TableView.indexPathForSelectedRow ?? IndexPath(row: 0, section: 0)
        let player1 = player1Choices[player1Index.row]
        let player2Index = player2TableView.indexPathForSelectedRow ?? IndexPath(row: 0, section: 0)
        let player2 = player2Choices[player2Index.row]
        playerSelectionDelegate?.setPlayers(player1Type: player1, player2Type: player2)

        dismiss(animated: true)
    }
}

extension NewGameViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == player1TableView {
            return player1Choices.count
        }

        return player2Choices.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.textAlignment = .center
        
        if tableView == player1TableView {
            cell.textLabel?.text = player1Choices[indexPath.row].rawValue
        }
        else {
            cell.textLabel?.text = player2Choices[indexPath.row].rawValue
        }

        return cell
    }
}

