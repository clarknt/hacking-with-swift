//
//  DetailViewController.swift
//  Project38
//
//  Created by clarknt on 2020-03-24.
//  Copyright © 2020 clarknt. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var detailLabel: UILabel!

    var detailItem: Commit?

    override func viewDidLoad() {
        super.viewDidLoad()

        if let detail = self.detailItem {
            detailLabel.text = detail.message
            // navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Commit 1/\(detail.author.commits.count)", style: .plain, target: self, action: #selector(showAuthorCommits))
        }
    }
}
