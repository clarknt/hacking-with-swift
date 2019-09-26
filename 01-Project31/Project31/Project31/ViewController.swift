//
//  ViewController.swift
//  Project31
//
//  Created by clarknt on 2019-09-24.
//  Copyright © 2019 clarknt. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate, UIGestureRecognizerDelegate, UITextFieldDelegate {

    @IBOutlet weak var addressBar: UITextField!
    @IBOutlet weak var stackView: UIStackView!

    // weak because the user might delete it at any time
    weak var activeWebView: WKWebView?

    override func viewDidLoad() {
        super.viewDidLoad()

        setDefaultTitle()

        let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addWebView))
        let delete = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteWebView))
        navigationItem.rightBarButtonItems = [delete, add]
    }

    func setDefaultTitle() {
        title = "Multibrowser"
    }

    @objc func addWebView() {
        let webView = WKWebView()
        webView.navigationDelegate = self

        // note: with stackView, do no call addSubview(:) but addArrangedSubview(:)
        stackView.addArrangedSubview(webView)

        let url = URL(string: "https://www.apple.com/")!
        webView.load(URLRequest(url: url))

        webView.layer.borderColor = UIColor.blue.cgColor
        selectWebView(webView)

        let recognizer = UITapGestureRecognizer(target: self, action: #selector(webViewTapped))
        recognizer.delegate = self
        webView.addGestureRecognizer(recognizer)
    }

    func selectWebView(_ webView: WKWebView) {
        print("hi")
        for view in stackView.arrangedSubviews {
            view.layer.borderWidth = 0
        }

        activeWebView = webView
        webView.layer.borderWidth = 3
    }

    @objc func webViewTapped(_ recognizer: UIGestureRecognizer) {
        print("Hello")
        if let selectedWebView = recognizer.view as? WKWebView {
            selectWebView(selectedWebView)
        }
    }

    @objc func deleteWebView() {

    }

    // MARK:- UIGestureRecognizerDelegate

    // allow tap gesture to be recognized along the the ones built in the webview
    // otherwise the gesture would be captured by the webview only
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        print("hey")
        return true
    }

    // MARK:- UITextFieldDelegate

    // return key pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let webView = activeWebView, let address = addressBar.text {
            if let url = URL(string: address) {
                webView.load(URLRequest(url: url))
            }
        }

        // hide the keyboard
        textField.resignFirstResponder()
        return true
    }
}