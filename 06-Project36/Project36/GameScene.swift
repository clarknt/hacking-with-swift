//
//  GameScene.swift
//  Project36
//
//  Created by clarknt on 2019-10-17.
//  Copyright © 2019 clarknt. All rights reserved.
//

import SpriteKit

enum GameState {
    case showingLogo
    case playing
    case dead
}

class GameScene: SKScene, SKPhysicsContactDelegate {

    var player: SKSpriteNode!
    var scoreLabel: SKLabelNode!

    var backgroundMusic: SKAudioNode!

    var logo: SKSpriteNode!
    var gameOver: SKSpriteNode!

    var gameState = GameState.showingLogo

    // store physics body so it's not recalculated every time
    // new rocks are added, avoiding slowdowns
    let rockTexture = SKTexture(imageNamed: "rock")
    var rockPhysics: SKPhysicsBody!

    // this constant is not used but will force preloading and caching the texture
    let explosion = SKEmitterNode(fileNamed: "PlayerExplosion")

    // challenge 1
    let rockTypes = ["rock", "plain_rock", "snow_rock", "ice_rock"]

    // challenge 2
    static let defaultRockDistance: CGFloat = 70
    // width of the gap between rocks - the smaller the harder
    var rockDistance = GameScene.defaultRockDistance

    var score = 0 {
        didSet {
            scoreLabel.text = "SCORE: \(score)"
        }
    }

    override func didMove(to view: SKView) {
        rockPhysics = SKPhysicsBody(texture: rockTexture, size: rockTexture.size())

        createPlayer()
        createSky()
        createBackground()
        createGround()
        createScore()
        createLogos()

        physicsWorld.gravity = CGVector(dx: 0.0, dy: -5.0)
        physicsWorld.contactDelegate = self

        if let musicURL = Bundle.main.url(forResource: "music", withExtension: "m4a") {
            backgroundMusic = SKAudioNode(url: musicURL)
            addChild(backgroundMusic)
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        switch gameState {
        case .showingLogo:
            gameState = .playing

            let fadeOut = SKAction.fadeOut(withDuration: 0.5)
            let remove = SKAction.removeFromParent()
            let wait = SKAction.wait(forDuration: 0.5)
            let activatePlayer = SKAction.run { [unowned self] in
                self.player.physicsBody?.isDynamic = true
                self.startRocks()
                // challenge 3
                self.startGold()
            }

            let sequence = SKAction.sequence([fadeOut, wait, activatePlayer, remove])
            logo.run(sequence)

        case .playing:
            // cancel previous velocity to avoid having it accumulate
            player.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            // apply upwards impulse
            player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 20))

        case .dead:
            if let scene = GameScene(fileNamed: "GameScene") {
                scene.scaleMode = .aspectFill
                let transition = SKTransition.moveIn(with: SKTransitionDirection.right, duration: 1)
                view?.presentScene(scene, transition: transition)
            }
        }
    }

    func createPlayer() {
        let playerTexture = SKTexture(imageNamed: "player-1")

        player = SKSpriteNode(texture: playerTexture)
        player.zPosition = 10

        // challenge 4
        let playerXPosition: CGFloat = 130

        player.position = CGPoint(x: playerXPosition, y: frame.height * 0.75)

        addChild(player)

        // pixel perfect physics
        player.physicsBody = SKPhysicsBody(texture: playerTexture, size: playerTexture.size())
        print(player.physicsBody!.collisionBitMask)
        // get notified of any collision
        player.physicsBody!.contactTestBitMask = player.physicsBody!.collisionBitMask
        // for the intro, make the plane NOT respond to physics
        player.physicsBody?.isDynamic = false
        // disable plane bounce
        player.physicsBody?.collisionBitMask = 0

        let frame2 = SKTexture(imageNamed: "player-2")
        let frame3 = SKTexture(imageNamed: "player-3")
        let animation = SKAction.animate(with: [playerTexture, frame2, frame3, frame2], timePerFrame: 0.01) // faster than refresh rate
        let runForever = SKAction.repeatForever(animation)

        player.run(runForever)
    }

    func createSky() {
        let topSky = SKSpriteNode(color: UIColor(hue: 0.55, saturation: 0.14, brightness: 0.97, alpha: 1), size: CGSize(width: frame.width, height: frame.height * 0.67))
        topSky.anchorPoint = CGPoint(x: 0.5, y: 1)

        let bottomSky = SKSpriteNode(color: UIColor(hue: 0.55, saturation: 0.16, brightness: 0.96, alpha: 1), size: CGSize(width: frame.width, height: frame.height * 0.33))
        bottomSky.anchorPoint = CGPoint(x: 0.5, y: 1)

        topSky.position = CGPoint(x: frame.midX, y: frame.height)
        bottomSky.position = CGPoint(x: frame.midX, y: bottomSky.frame.height)

        addChild(topSky)
        addChild(bottomSky)

        bottomSky.zPosition = -40
        topSky.zPosition = -40
    }

    func createBackground() {
        let backgroundTexture = SKTexture(imageNamed: "background")

        for i in 0...1 {
            let background = SKSpriteNode(texture: backgroundTexture)
            background.zPosition = -30
            background.anchorPoint = CGPoint.zero
            background.position = CGPoint(x: (backgroundTexture.size().width * CGFloat(i)) - CGFloat(1 * i), y: 100)
            addChild(background)

            let moveLeft = SKAction.moveBy(x: -backgroundTexture.size().width, y: 0, duration: 20)
            let moveReset = SKAction.moveBy(x: backgroundTexture.size().width, y: 0, duration: 0)
            let moveLoop = SKAction.sequence([moveLeft, moveReset])
            let moveForever = SKAction.repeatForever(moveLoop)

            background.run(moveForever)
        }
    }

    func createGround() {
        let groundTexture = SKTexture(imageNamed: "ground")

        for i in 0...1 {
            let ground = SKSpriteNode(texture: groundTexture)
            ground.zPosition = -10
            // - CGFloat(1 * i) to overlap by 1 pixel, avoiding some flicker
            ground.position = CGPoint(x: (groundTexture.size().width / 2.0 + (groundTexture.size().width * CGFloat(i))) - CGFloat(1 * i), y: groundTexture.size().height / 2)

            // pixel perfect collision detection
            ground.physicsBody = SKPhysicsBody(texture: ground.texture!, size: ground.texture!.size())
            // don't be moved by the collision
            ground.physicsBody?.isDynamic = false

            addChild(ground)

            let moveLeft = SKAction.moveBy(x: -groundTexture.size().width, y: 0, duration: 5)
            let moveReset = SKAction.moveBy(x: groundTexture.size().width, y: 0, duration: 0)
            let moveLoop = SKAction.sequence([moveLeft, moveReset])
            let moveForever = SKAction.repeatForever(moveLoop)

            ground.run(moveForever)
        }
    }

    func createRocks() {
        // sometiimes
        guard rockPhysics.copy() as? SKPhysicsBody != nil else { return }

        // challenge 1
        let rockTexture = SKTexture(imageNamed: rockTypes.randomElement()!)

        let topRock = SKSpriteNode(texture: rockTexture)
        // allow collision detection
        topRock.physicsBody = rockPhysics.copy() as? SKPhysicsBody
        // disable physics (including gravity) on the rocks
        topRock.physicsBody?.isDynamic = false

        // use the same texture for top, but rotated
        topRock.zRotation = .pi
        topRock.xScale = -1.0

        let bottomRock = SKSpriteNode(texture: rockTexture)
        bottomRock.physicsBody = rockPhysics.copy() as? SKPhysicsBody
        bottomRock.physicsBody?.isDynamic = false

        topRock.zPosition = -20
        bottomRock.zPosition = -20

        // large rectangle positioned just after the rocks and will be used to track
        // when the player has passed through the rocks safely – if they touch that
        // rectangle, they should score a point
        let rockCollision = SKSpriteNode(color: UIColor.clear, size: CGSize(width: 32, height: frame.height))
        // rectangle collision detection this time (faster than pixel-perfect)
        rockCollision.physicsBody = SKPhysicsBody(rectangleOf: rockCollision.size)
        rockCollision.physicsBody?.isDynamic = false

        rockCollision.name = "scoreDetect"

        addChild(topRock)
        addChild(bottomRock)
        addChild(rockCollision)

        let xPosition = frame.width + topRock.frame.width

        let max = CGFloat(frame.height / 3)
        // position of the gap between the rocks
        let yPosition = CGFloat.random(in: -50...max)

        // challenge 2
        rockDistance *= 0.99

        // position the rocks and animate from right to left
        topRock.position = CGPoint(x: xPosition, y: yPosition + topRock.size.height + rockDistance)
        bottomRock.position = CGPoint(x: xPosition, y: yPosition - rockDistance)
        rockCollision.position = CGPoint(x: xPosition + (rockCollision.size.width * 2), y: frame.midY)

        let endPosition = frame.width + (topRock.frame.width * 2)

        // challenge 3
        // set to 7.3 instead of 6.2 to accomodate different rocks size (7.2 is
        // the same speed as ground but 7.3 gives a very slight parallax effect
        // which works well because the rocks are behind the ground)
        let moveAction = SKAction.moveBy(x: -endPosition, y: 0, duration: 7.3)
        let moveSequence = SKAction.sequence([moveAction, SKAction.removeFromParent()])
        topRock.run(moveSequence)
        bottomRock.run(moveSequence)
        rockCollision.run(moveSequence)
    }

    func startRocks() {
        // challenge 2
        rockDistance = GameScene.defaultRockDistance

        let create = SKAction.run { [unowned self] in
            self.createRocks()
        }

        let wait = SKAction.wait(forDuration: 3)
        let sequence = SKAction.sequence([create, wait])
        let repeatForever = SKAction.repeatForever(sequence)

        run(repeatForever)
    }

    // challenge 3
    func createGold() {
        let gold = SKSpriteNode(imageNamed: "gold")
        // allow collision detection
        gold.physicsBody = SKPhysicsBody(circleOfRadius: gold.size.width / 2)
        gold.physicsBody?.isDynamic = false

        gold.name = "gold"

        addChild(gold)

        // start after the first rock
        let xMiddle = frame.width * 2
        let xLeftRange = xMiddle //+ (frame.width / 16)
        let xRightRange = xMiddle + (frame.width / 2.5)
        let xPosition = CGFloat.random(in: xLeftRange...xRightRange)

        let yMiddle = frame.height / 2
        let yTopRange = yMiddle + (frame.height / 3)
        let yBottomRange = yMiddle - (frame.height / 3)
        let yPosition = CGFloat.random(in: yBottomRange...yTopRange)

        // position and animate from right to left
        gold.position = CGPoint(x: xPosition, y: yPosition)

        // go away enough
        let endPosition = frame.width * 3

        // same settings as the rocks
        let moveAction = SKAction.moveBy(x: -endPosition, y: 0, duration: 9.5)
        let moveSequence = SKAction.sequence([moveAction, SKAction.removeFromParent()])
        gold.run(moveSequence)
    }

    // challenge 3
    func startGold() {
        let create = SKAction.run { [unowned self] in
            self.createGold()
        }

        let wait = SKAction.wait(forDuration: 3)
        let sequence = SKAction.sequence([create, wait])
        let repeatForever = SKAction.repeatForever(sequence)

        run(repeatForever)
    }

    func createScore() {
        scoreLabel = SKLabelNode(fontNamed: "Optima-ExtraBlack")
        scoreLabel.fontSize = 24

        scoreLabel.position = CGPoint(x: frame.midX, y: frame.maxY - 60)
        scoreLabel.text = "SCORE: 0"
        scoreLabel.fontColor = UIColor.black

        addChild(scoreLabel)
    }

    override func update(_ currentTime: TimeInterval) {
        guard player != nil else { return }

        // angle the plane slightly while going up or down
        let value = player.physicsBody!.velocity.dy * 0.001
        let rotate = SKAction.rotate(toAngle: value, duration: 0.1)

        player.run(rotate)
    }

    func didBegin(_ contact: SKPhysicsContact) {
        // challenge 3
        var rectangleCollision = false
        var coinCollision = false

        // collision with the score detection rectangle?
        if contact.bodyA.node?.name == "scoreDetect" || contact.bodyB.node?.name == "scoreDetect" {
            rectangleCollision = true
        }

        // collision with a coin?
        if contact.bodyA.node?.name == "gold" || contact.bodyB.node?.name == "gold" {
            coinCollision = true
        }

        if rectangleCollision || coinCollision {
            if contact.bodyA.node == player {
                contact.bodyB.node?.removeFromParent()
            } else {
                contact.bodyA.node?.removeFromParent()
            }

            let sound = SKAction.playSoundFileNamed("coin.wav", waitForCompletion: false)
            run(sound)

            score += 1

            return
        }

        // avoid possible double collision detection (player against rectangle,
        // then rectangle against player)
        guard contact.bodyA.node != nil && contact.bodyB.node != nil else {
            return
        }

        if contact.bodyA.node == player || contact.bodyB.node == player {
            if let explosion = SKEmitterNode(fileNamed: "PlayerExplosion") {
                explosion.position = player.position
                addChild(explosion)
            }

            let sound = SKAction.playSoundFileNamed("explosion.wav", waitForCompletion: false)
            run(sound)

            gameOver.alpha = 1
            gameState = .dead
            backgroundMusic.run(SKAction.stop())

            player.removeFromParent()
            speed = 0
        }
    }

    func createLogos() {
        logo = SKSpriteNode(imageNamed: "logo")
        logo.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(logo)

        gameOver = SKSpriteNode(imageNamed: "gameover")
        gameOver.position = CGPoint(x: frame.midX, y: frame.midY)
        gameOver.alpha = 0
        addChild(gameOver)
    }
}
