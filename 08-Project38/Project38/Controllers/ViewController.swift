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

    var commitPredicate: NSPredicate?

    var fetchedResultsController: NSFetchedResultsController<Commit>!

    let usePagination = true

    // challenge 3
    var userStorage = UserStorage()

    override func viewDidLoad() {
        super.viewDidLoad()

        container = NSPersistentContainer(name: "Project38")

        container.loadPersistentStores { storeDescription, error in
            self.container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

            if let error = error {
                print("Unresolved error \(error)")
            }
        }

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Filter", style: .plain, target: self, action: #selector(changeFilter))

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
        let newestCommitDate = getNewestCommitDate()

        //if let data = try? String(contentsOf: URL(string: "https://api.github.com/repos/apple/swift/commits?per_page=100")!) {
        if let data = try? String(contentsOf: URL(string: "https://api.github.com/repos/apple/swift/commits?per_page=100&since=\(newestCommitDate)")!) {

            // give the data to SwiftyJSON to parse
            let jsonCommits = JSON(parseJSON: data)

            // read the commits back out
            let jsonCommitArray = jsonCommits.arrayValue

            print("Received \(jsonCommitArray.count) new commits.")

            // challenge 3
            var newestDate: Date?

            DispatchQueue.main.async { [unowned self] in
                // reverse to get a creationDate matching commit orders
                for jsonCommit in jsonCommitArray.reversed() {
                    // the following three lines are new
                    let commit = Commit(context: self.container.viewContext)
                    self.configure(commit: commit, usingJSON: jsonCommit)

                    // challenge 3
                    if let unwrappedNewestDate = newestDate {
                        if commit.date > unwrappedNewestDate {
                            newestDate = commit.date
                        }
                    }
                    else {
                        newestDate = commit.date
                    }
                }

                self.saveContext()

                self.loadSavedData()

                // challenge 3
                if let unwrappedNewestDate = newestDate {
                    self.saveNewestCommitDate(date: unwrappedNewestDate)
                }
            }
        }
    }

    func configure(commit: Commit, usingJSON json: JSON) {
        commit.sha = json["sha"].stringValue
        commit.message = json["commit"]["message"].stringValue
        commit.url = json["html_url"].stringValue

        let formatter = ISO8601DateFormatter()
        commit.date = formatter.date(from: json["commit"]["committer"]["date"].stringValue) ?? Date()

        var commitAuthor: Author!

        // see if this author exists already
        let authorRequest = Author.createFetchRequest()
        authorRequest.predicate = NSPredicate(format: "name == %@", json["commit"]["committer"]["name"].stringValue)

        if let authors = try? container.viewContext.fetch(authorRequest) {
            if authors.count > 0 {
                // we have this author already
                commitAuthor = authors[0]
            }
        }

        if commitAuthor == nil {
            // we didn't find a saved author - create a new one!
            let author = Author(context: container.viewContext)
            author.name = json["commit"]["committer"]["name"].stringValue
            author.email = json["commit"]["committer"]["email"].stringValue
            commitAuthor = author
        }

        // use the author, either saved or new
        commit.author = commitAuthor

        commit.creationDate = Date().timeIntervalSince1970

        if commit.author.name == "Dan Zheng" {
            print(commit.date, commit.author.name, commit.creationDate, commit.message)
        }
    }

    func getNewestCommitDate() -> String {
        // challenge 3
        let formatter = ISO8601DateFormatter()
        return formatter.string(from: userStorage.newestCommitDate.addingTimeInterval(1))

        // version before challenge 3
        //let formatter = ISO8601DateFormatter()
        //
        //let newest = Commit.createFetchRequest()
        //let sort = NSSortDescriptor(key: "date", ascending: false)
        //newest.sortDescriptors = [sort]
        //newest.fetchLimit = 1
        //
        //if let commits = try? container.viewContext.fetch(newest) {
        //    if commits.count > 0 {
        //        return formatter.string(from: commits[0].date.addingTimeInterval(1))
        //    }
        //}
        //
        //return formatter.string(from: Date(timeIntervalSince1970: 0))
    }

    // challenge 3
    func saveNewestCommitDate(date: Date) {
        print("Saving \(date)")
        userStorage.newestCommitDate = date
    }

    func loadSavedData() {
        if usePagination {
            loadPaginatedSavedData()
        }
        else {
            loadUnpaginatedSavedData()
        }
    }

    // version that loads only 20 results
    func loadPaginatedSavedData() {
        if fetchedResultsController == nil {
            let request = Commit.createFetchRequest()
            let authorNameSort = NSSortDescriptor(key: "author.name", ascending: true)
            let creationDateSort = NSSortDescriptor(key: "creationDate", ascending: false)
            request.sortDescriptors = [authorNameSort, creationDateSort]

            // to sort by date instead of author
            //let sort = NSSortDescriptor(key: "date", ascending: false)
            //request.sortDescriptors = [sort]
            request.fetchBatchSize = 20

            fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: container.viewContext, sectionNameKeyPath: "author.name", cacheName: nil)
            // to display without sections
            // fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: container.viewContext, sectionNameKeyPath: nil, cacheName: nil)
            fetchedResultsController.delegate = self
        }

        fetchedResultsController.fetchRequest.predicate = commitPredicate

        do {
            try fetchedResultsController.performFetch()
//            tableView.reloadData()
        } catch {
            print("Fetch failed")
        }
    }

    // version that loads everything
    func loadUnpaginatedSavedData() {
        let request = Commit.createFetchRequest()
        let sort = NSSortDescriptor(key: "date", ascending: false)
        request.sortDescriptors = [sort]
        request.predicate = commitPredicate

        do {
            commits = try container.viewContext.fetch(request)
            print("Got \(commits.count) commits")
            tableView.reloadData()
        } catch {
            print("Fetch failed")
        }
    }

    @objc func changeFilter() {
        let ac = UIAlertController(title: "Filter commits…", message: nil, preferredStyle: .actionSheet)

        ac.addAction(UIAlertAction(title: "Show only fixes", style: .default) { [unowned self] _ in
            // [c]: case insensitive
            self.commitPredicate = NSPredicate(format: "message CONTAINS[c] 'fix'")
            self.loadSavedData()
        })

        ac.addAction(UIAlertAction(title: "Ignore Pull Requests", style: .default) { [unowned self] _ in
            self.commitPredicate = NSPredicate(format: "NOT message BEGINSWITH 'Merge pull request'")
            self.loadSavedData()
        })

        ac.addAction(UIAlertAction(title: "Show only recent", style: .default) { [unowned self] _ in
            // 43200 seconds: half a day
            let twelveHoursAgo = Date().addingTimeInterval(-43200)
            self.commitPredicate = NSPredicate(format: "date > %@", twelveHoursAgo as NSDate)
            self.loadSavedData()
        })

        ac.addAction(UIAlertAction(title: "Show only Joe's commits", style: .default) { [unowned self] _ in
            self.commitPredicate = NSPredicate(format: "author.name == 'Joe Groff'")
            self.loadSavedData()
        })

        // add more name to get some results
        ac.addAction(UIAlertAction(title: "Show only Pavel's commits", style: .default) { [unowned self] _ in
            self.commitPredicate = NSPredicate(format: "author.name == 'Pavel Yaskevich'")
            self.loadSavedData()
        })

        ac.addAction(UIAlertAction(title: "Show only Mike's commits", style: .default) { [unowned self] _ in
            self.commitPredicate = NSPredicate(format: "author.name == 'Mike Ash'")
            self.loadSavedData()
        })

        ac.addAction(UIAlertAction(title: "Show all commits", style: .default) { [unowned self] _ in
            self.commitPredicate = nil
            self.loadSavedData()
        })

        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
}

// MARK:- UITableViewDataSource

extension ViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        if usePagination {
            return fetchedResultsController.sections?.count ?? 0
        }
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if usePagination {
            let sectionInfo = fetchedResultsController.sections![section]
            return sectionInfo.numberOfObjects
        }
        return commits.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return fetchedResultsController.sections![section].name
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Commit", for: indexPath)

        let commit: Commit
        if usePagination {
            commit = fetchedResultsController.object(at: indexPath)
        }
        else {
            commit = commits[indexPath.row]
        }
        cell.textLabel!.text = commit.message
        cell.detailTextLabel!.text = "By \(commit.author.name) on \(commit.date.description)"

        return cell
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if usePagination {
                let commit = fetchedResultsController.object(at: indexPath)
                container.viewContext.delete(commit)
            }
            else {
                let commit = commits[indexPath.row]
                container.viewContext.delete(commit)
                commits.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            saveContext()
        }
    }
}

// MARK:- UITableViewDelegate

extension ViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
            if usePagination {
                vc.detailItem = fetchedResultsController.object(at: indexPath)
            }
            else {
                vc.detailItem = commits[indexPath.row]
            }
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

// MARK:- NSFetchedResultsControllerDelegate

extension ViewController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {

        switch type {

        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .automatic)

        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .automatic)

        default:
            break
        }
    }

    // challenge 5
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {

        switch type {

        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .automatic)

        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)

        default:
            break
        }
    }

    // challenge 5
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }

    // challenge 5
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}
