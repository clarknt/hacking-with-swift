//
//  DetailViewController.swift
//  Project38
//
//  Created by clarknt on 2020-03-24.
//  Copyright © 2020 clarknt. All rights reserved.
//

import UIKit
import WebKit

class DetailViewController: UIViewController {

    // challenge 2
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    var detailItem: Commit?

    override func viewDidLoad() {
        super.viewDidLoad()

        // challenge 2
        activityIndicator.hidesWhenStopped = true
        webView.navigationDelegate = self

        if let detail = self.detailItem {
            // navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Commit 1/\(detail.author.commits.count)", style: .plain, target: self, action: #selector(showAuthorCommits))

            // challenge 2
            if let url = URL(string: detail.url) {
                webView.load(URLRequest(url: url))
                webView.allowsBackForwardNavigationGestures = true
            }
        }
    }
}

// challenge 2
extension DetailViewController: WKNavigationDelegate {
    func showActivityIndicator(show: Bool) {
        if show {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        showActivityIndicator(show: false)
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        showActivityIndicator(show: true)
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        showActivityIndicator(show: false)
    }
}
