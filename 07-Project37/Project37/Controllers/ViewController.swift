//
//  ViewController.swift
//  Project37
//
//  Created by clarknt on 2020-03-17.
//  Copyright © 2020 clarknt. All rights reserved.
//

import AVFoundation
import UIKit
import WatchConnectivity

class ViewController: UIViewController {

    @IBOutlet weak var cardContainer: UIView!
    @IBOutlet weak var gradientView: UIView!

    var allCards = [CardViewController]()

    var music: AVAudioPlayer!

    var lastMessage: CFAbsoluteTime = 0

    // challenge 1
    var soundPlayer: AVAudioPlayer!

    // challange 2
    var allStarMode = false

    override func viewDidLoad() {
        super.viewDidLoad()

        animateBackground()

        createParticles()
        
        loadCards()

        playMusic()

        if (WCSession.isSupported()) {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let instructions = "Please ensure your Apple Watch is configured correctly. On your iPhone, launch Apple's 'Watch' configuration app then choose General > Wake Screen. On that screen, please disable Wake Screen On Wrist Raise, then select Wake For 70 Seconds. On your Apple Watch, please swipe up on your watch face and enable Silent Mode. You're done!"
        let ac = UIAlertController(title: "Adjust your settings", message: instructions, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "I'm Ready", style: .default))
        present(ac, animated: true)
    }

    func animateBackground() {
        view.backgroundColor = UIColor.red

        UIView.animate(withDuration: 20, delay: 0, options: [.allowUserInteraction, .autoreverse, .repeat], animations: {
            self.view.backgroundColor = UIColor.blue
        })
    }

    @objc func loadCards() {
        // remove previous cards
        for card in allCards {
            card.view.removeFromSuperview()
            card.removeFromParent()
        }

        allCards.removeAll(keepingCapacity: true)

        // create an array of card positions
        let positions = [
            CGPoint(x: 75, y: 85),
            CGPoint(x: 185, y: 85),
            CGPoint(x: 295, y: 85),
            CGPoint(x: 405, y: 85),
            CGPoint(x: 75, y: 235),
            CGPoint(x: 185, y: 235),
            CGPoint(x: 295, y: 235),
            CGPoint(x: 405, y: 235)
        ]

        // load and unwrap our Zener card images
        let circle = UIImage(named: "cardCircle")!
        let cross = UIImage(named: "cardCross")!
        let lines = UIImage(named: "cardLines")!
        let square = UIImage(named: "cardSquare")!
        let star = UIImage(named: "cardStar")!

        // create an array of the images, one for each card, then shuffle it
        var images = [circle, circle, cross, cross, lines, lines, square, star]
        images.shuffle()

        view.isUserInteractionEnabled = true

        for (index, position) in positions.enumerated() {
            // loop over each card position and create a new card view controller
            let card = CardViewController()
            card.delegate = self

            // use view controller containment and also add the card's view to our cardContainer view
            addChild(card)
            cardContainer.addSubview(card.view)
            card.didMove(toParent: self)

            // position the card appropriately, then give it an image from our array
            card.view.center = position
            card.front.image = images[index]

            // if we just gave the new card the star image, mark this as the correct answer
            if card.front.image == star {
                card.isCorrect = true
            }

            // add the new card view controller to our array for easier tracking
            allCards.append(card)
        }
    }

    func cardTapped(_ tapped: CardViewController) {
        guard view.isUserInteractionEnabled == true else { return }
        view.isUserInteractionEnabled = false

        for card in allCards {
            if card == tapped {
                // challenge 2
                if allStarMode {
                    card.front.image = UIImage(named: "cardStar")
                    card.isCorrect = true
                }

                card.wasTapped()
                card.perform(#selector(card.wasntTapped), with: nil, afterDelay: 1)
            } else {
                card.wasntTapped()
            }
        }

        perform(#selector(loadCards), with: nil, afterDelay: 2)
    }

    func createParticles() {
        let particleEmitter = CAEmitterLayer()

        particleEmitter.emitterPosition = CGPoint(x: view.frame.width / 2.0, y: -50)
        particleEmitter.emitterShape = .line
        particleEmitter.emitterSize = CGSize(width: view.frame.width, height: 1)
        particleEmitter.renderMode = .additive

        let cell = CAEmitterCell()
        cell.birthRate = 2
        cell.lifetime = 5.0
        cell.velocity = 100
        cell.velocityRange = 50
        cell.emissionLongitude = .pi
        cell.spinRange = 5
        cell.scale = 0.5
        cell.scaleRange = 0.25
        cell.color = UIColor(white: 1, alpha: 0.1).cgColor
        cell.alphaSpeed = -0.025
        cell.contents = UIImage(named: "particle")?.cgImage
        particleEmitter.emitterCells = [cell]

        gradientView.layer.addSublayer(particleEmitter)
    }

    func playMusic() {
        if let musicURL = Bundle.main.url(forResource: "PhantomFromSpace", withExtension: "mp3") {
            if let audioPlayer = try? AVAudioPlayer(contentsOf: musicURL) {
                music = audioPlayer
                music.numberOfLoops = -1
                music.play()
            }
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)

        guard let touch = touches.first else { return }
        let location = touch.location(in: cardContainer)

        for card in allCards {
            if card.view.frame.contains(location) {
                if view.traitCollection.forceTouchCapability == .available {
                    if touch.force == touch.maximumPossibleForce {
                        card.front.image = UIImage(named: "cardStar")
                        card.isCorrect = true
                    }
                }

                if card.isCorrect {
                    sendWatchMessage()
                }
            }
        }
    }

    func sendWatchMessage() {
        let currentTime = CFAbsoluteTimeGetCurrent()

        // if less than 0.2 second has passed, bail out
        if lastMessage + 0.2 > currentTime {
            return
        }

        // send a message to the watch if it's reachable
        if (WCSession.default.isReachable) {
            // this is a meaningless message, but it's enough for our purposes
            let message = ["Message": "Hello"]
            WCSession.default.sendMessage(message, replyHandler: nil)
        }

        // update our rate limiting property
        lastMessage = CFAbsoluteTimeGetCurrent()
    }
}

extension ViewController: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    }

    func sessionDidBecomeInactive(_ session: WCSession) {
    }

    func sessionDidDeactivate(_ session: WCSession) {
    }

    // challenge 1 (using sessionReachabilityDidChange instead of the suggested sessionWatchStateDidChange)
    func sessionReachabilityDidChange(_ session: WCSession) {
        if session.isReachable == false {
            playUnreachableSound()
        }
    }

    // challenge 1
    func playUnreachableSound() {
        if let musicURL = Bundle.main.url(forResource: "267412__shandonsound__coin-drop-1", withExtension: "aiff") {
            if let audioPlayer = try? AVAudioPlayer(contentsOf: musicURL) {
                soundPlayer = audioPlayer
                soundPlayer.numberOfLoops = 0
                soundPlayer.play()
            }
        }
    }

    // challenge 2
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("Message received")
        if let asm = message["AllStarMode"] as? Bool {
            allStarMode = asm
        }
    }
}
