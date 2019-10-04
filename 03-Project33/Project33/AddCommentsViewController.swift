//
//  AddCommentsViewController.swift
//  Project33
//
//  Created by clarknt on 2019-10-03.
//  Copyright © 2019 clarknt. All rights reserved.
//

import UIKit

class AddCommentsViewController: UIViewController, UITextViewDelegate {

    var genre: String!


    var comments: UITextView!
    let placeholder = "If you have any additional comments that might help identify your tune, enter them here."

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Comments"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Submit", style: .plain, target: self, action: #selector(submitTapped))
        comments.text = placeholder
        comments.textColor = UIColor.gray // might not work well with iOS 13 dark mode
    }

    @objc func submitTapped() {
//        let vc = SubmitViewController()
//        vc.genre = genre
//
//        if comments.text == placeholder {
//            vc.comments = ""
//        }
//        else {
//            vc.comments = comments.text
//        }
//
//        navigationController?.pushViewController(vc, animated: true)
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == placeholder {
            textView.text = ""
            textView.textColor = UIColor.darkText // might not work well with iOS 13 dark mode
        }
    }

    override func loadView() {
        view = UIView()
        view.backgroundColor = UIColor.white

        comments = UITextView()
        comments.translatesAutoresizingMaskIntoConstraints = false
        comments.delegate = self
        comments.font = UIFont.preferredFont(forTextStyle: .body)
        view.addSubview(comments)

        comments.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        comments.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        comments.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        comments.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }
}
