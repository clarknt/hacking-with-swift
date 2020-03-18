//
//  InterfaceController.swift
//  Project37 WatchKit Extension
//
//  Created by clarknt on 2020-03-17.
//  Copyright © 2020 clarknt. All rights reserved.
//

import Foundation
import WatchConnectivity
import WatchKit


class InterfaceController: WKInterfaceController, WCSessionDelegate {
    @IBOutlet weak var welcomeText: WKInterfaceLabel!
    @IBOutlet weak var hideButton: WKInterfaceButton!

    // challenge 2
    @IBOutlet weak var allStarButton: WKInterfaceButton!

    // challenge 2
    public var allStarMode = false {
        didSet {
            if allStarMode {
                print("Watch haptic start effect")
                WKInterfaceDevice().play(.start)
            }
            else {
                print("Watch haptic stop effect")
                WKInterfaceDevice().play(.stop)
            }
        }
    }

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()

        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    @IBAction func hideWelcomeText() {
        welcomeText.setHidden(true)
        hideButton.setHidden(true)
        allStarButton.setHidden(false)
    }

    // challenge 2
    @IBAction func allStarTapped() {
        allStarMode.toggle()

        // note: in WatchKit Extension target,
        // "Supports running without iOS App installation"
        // must be unchecked for this to work
        if (WCSession.default.isReachable) {
            let message = ["AllStarMode": allStarMode]
            WCSession.default.sendMessage(message, replyHandler: nil)
        }
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) { }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("Watch haptic click effect")
        WKInterfaceDevice().play(.click)
    }
}
