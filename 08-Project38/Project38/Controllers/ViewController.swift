//
//  ViewController.swift
//  Project38
//
//  Created by clarknt on 2020-03-24.
//  Copyright © 2020 clarknt. All rights reserved.
//

import CoreData
import UIKit

class ViewController: UITableViewController {

    var container: NSPersistentContainer!

    var commits = [Commit]()

    override func viewDidLoad() {
        super.viewDidLoad()

        container = NSPersistentContainer(name: "Project38")

        container.loadPersistentStores { storeDescription, error in
            if let error = error {
                print("Unresolved error \(error)")
            }
        }

        performSelector(inBackground: #selector(fetchCommits), with: nil)

        loadSavedData()
    }

    func saveContext() {
        if container.viewContext.hasChanges {
            do {
                try container.viewContext.save()
            } catch {
                print("An error occurred while saving: \(error)")
            }
        }
    }

    @objc func fetchCommits() {
        if let data = try? String(contentsOf: URL(string: "https://api.github.com/repos/apple/swift/commits?per_page=100")!) {
            // give the data to SwiftyJSON to parse
            let jsonCommits = JSON(parseJSON: data)

            // read the commits back out
            let jsonCommitArray = jsonCommits.arrayValue

            print("Received \(jsonCommitArray.count) new commits.")

            DispatchQueue.main.async { [unowned self] in
                for jsonCommit in jsonCommitArray {
                    // the following three lines are new
                    let commit = Commit(context: self.container.viewContext)
                    self.configure(commit: commit, usingJSON: jsonCommit)
                }

                self.saveContext()

                self.loadSavedData()
            }
        }
    }

    func configure(commit: Commit, usingJSON json: JSON) {
        commit.sha = json["sha"].stringValue
        commit.message = json["commit"]["message"].stringValue
        commit.url = json["html_url"].stringValue

        let formatter = ISO8601DateFormatter()
        commit.date = formatter.date(from: json["commit"]["committer"]["date"].stringValue) ?? Date()
    }

    func loadSavedData() {
        let request = Commit.createFetchRequest()
        let sort = NSSortDescriptor(key: "date", ascending: false)
        request.sortDescriptors = [sort]

        do {
            commits = try container.viewContext.fetch(request)
            print("Got \(commits.count) commits")
            tableView.reloadData()
        } catch {
            print("Fetch failed")
        }
    }
}

// MARK:- UITableViewDataSource

extension ViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commits.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Commit", for: indexPath)

        let commit = commits[indexPath.row]
        cell.textLabel!.text = commit.message
        cell.detailTextLabel!.text = commit.date.description

        return cell
    }
}
