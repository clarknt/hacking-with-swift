//
//  SubmitViewController.swift
//  Project33
//
//  Created by clarknt on 2020-10-27.
//  Copyright © 2020 clarknt. All rights reserved.
//

import CloudKit
import UIKit

class SubmitViewController: UIViewController {

    var genre: String!
    var comments: String!

    var stackView: UIStackView!
    var status: UILabel!
    var spinner: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "You're all set!"
        navigationItem.hidesBackButton = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        doSubmission()
    }

    func doSubmission() {
        let whistleRecord = CKRecord(recordType: "Whistles")
        whistleRecord["genre"] = genre as CKRecordValue
        whistleRecord["comments"] = comments as CKRecordValue

        let audioURL = RecordWhistleViewController.getWhistleURL()
        let whistleAsset = CKAsset(fileURL: audioURL)
        whistleRecord["audio"] = whistleAsset

        CKContainer.default().publicCloudDatabase.save(whistleRecord) { [unowned self] record, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.status.text = "Error: \(error.localizedDescription)"
                    self.spinner.stopAnimating()
                }
                else {
                    self.view.backgroundColor = UIColor(red: 0, green: 0.6, blue: 0, alpha: 1)
                    self.status.text = "Done!"
                    self.spinner.stopAnimating()

                    ViewController.isDirty = true
                }

                self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.doneTapped))
            }
        }
    }

    @objc func doneTapped() {
        _ = navigationController?.popToRootViewController(animated: true)
    }

    override func loadView() {
        view = UIView()
        view.backgroundColor = UIColor.systemGray

        stackView = UIStackView()
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = UIStackView.Distribution.fillEqually
        stackView.alignment = .center
        stackView.axis = .vertical
        view.addSubview(stackView)

        stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true

        status = UILabel()
        status.translatesAutoresizingMaskIntoConstraints = false
        status.text = "Submitting..."
        status.font = UIFont.preferredFont(forTextStyle: .title1)
        status.numberOfLines = 0
        status.textAlignment = .center

        if #available(iOS 13.0, *) {
            spinner = UIActivityIndicatorView(style: .whiteLarge)
        }
        else {
            spinner = UIActivityIndicatorView(style: .white)
        }
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.hidesWhenStopped = true
        spinner.startAnimating()

        stackView.addArrangedSubview(status)
        stackView.addArrangedSubview(spinner)
    }

}
