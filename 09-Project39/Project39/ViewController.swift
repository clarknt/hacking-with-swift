//
//  ViewController.swift
//  Project39
//
//  Created by clarknt on 2020-04-08.
//  Copyright © 2020 clarknt. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {

    var playData = PlayData()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
}

// MARK:- UITableViewDataSource

extension ViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playData.allWords.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let word = playData.allWords[indexPath.row]
        cell.textLabel!.text = word
        return cell
    }
}

