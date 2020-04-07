//
//  AuthorViewController.swift
//  Project38
//
//  Created by clarknt on 2020-04-06.
//  Copyright © 2020 clarknt. All rights reserved.
//

import UIKit

// Challenge 4

class AuthorViewController: UITableViewController {

    var commit: Commit?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = commit?.author.name
    }

    override func viewDidAppear(_ animated: Bool) {
        // select and scroll to currently viewed commit
        if let commit = commit {
            let row = commit.author.commits.count - commit.author.commits.index(of: commit) - 1
            tableView.selectRow(at: IndexPath(row: row, section: 0), animated: true, scrollPosition: .top)
        }
    }
}

// MARK: - Table view data source

extension AuthorViewController {

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commit?.author.commits.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Commit", for: indexPath)

        if
            let commits = commit?.author.commits,
            let commit = commits.object(at: commits.count - indexPath.row - 1) as? Commit
        {
            cell.textLabel?.text = commit.date.description
            cell.detailTextLabel?.text = commit.message
        }

        return cell
    }
}
