//
//  GameScene.swift
//  Game Tut 17
//
//  Created by Clint Sellen on 30/4/18.
//  Copyright © 2018 UTS. All rights reserved.
//
//References
//https://www.hackingwithswift.com/read
//https://github.com/Bashta/SpritekitSceneDelegation
//https://code.tutsplus.com/tutorials/game-center-and-leaderboards-for-your-ios-app--cms-27488
//https://www.swiftbysundell.com/posts/using-spritekit-to-create-animations-in-swift
//http://joyfulgames.io/saving-spritekit-game-data-swift-easy-nscoder/
//https://b4sht4.wordpress.com/2014/12/02/implementing-a-delegate-pattern-between-spritekit-scenes/
//https://help.apple.com/xcode/mac/current/#/devea503dbda
//https://stackoverflow.com/questions/3087089/xcode-build-and-archive-menu-item-disabled
//https://developer.apple.com/documentation/gamekit/gkplayer/1520695-displayname

import SpriteKit
import GameplayKit

protocol GameSceneDelegate {
    func gameOver()
}

// Type of bubble launches
enum SequenceType: Int {
    case one, halfMax, max, chain, fastChain
}

class GameScene: SKScene {
// Declere view controller
    weak var viewController: GameViewController!
//    Declare delegate
    var gameSceneDelegate: GameSceneDelegate?
    var gameKitEnabled: Bool = true
// View Parameters
    var viewWidth = 1024
    var viewHeight = 750
    // Slice variables for touch
    var activeSlicePoints = [CGPoint]()
    var activeSliceBG: SKShapeNode!
    var activeSliceFG: SKShapeNode!
    var isSwooshSoundActive = false
// Game play parameters
    var popupTime = 0.5
    var gravity = -6.0
    var sequence: [SequenceType]!
    var sequencePosition = 0
    var chainDelay = 3.0
    var nextSequenceQueued = true
// Bubble parameters
    var activeBubbles = [SKSpriteNode]()
    var maxActiveBubbles: Int = 15
    var multiplierLabel: SKLabelNode!
    var addToScoreLabel: SKLabelNode!
    var topScoreLabel: SKLabelNode!
    var topScore = 0
// Start countdown
    let startTimerLable = SKLabelNode(fontNamed: "Avenir Next Condensed Bold")
    var startCountDown: Timer!
    var startTime = 3
    var istimerAnimationOn: Bool = false
// Last bubble popped menu
    var lastBubbblePopImageContainer = [SKSpriteNode]()
    var lastPoppedName: String = "No Popped"
    var lastBubbblePopImage: SKSpriteNode!
    var pointsMultiplier: Float = 1.0
// Game timer menu
    let clockLabel = SKLabelNode(fontNamed: "Avenir Next Condensed Bold")
    var gameTimer: Timer!
    var gameTime = 60.0
// End game
    var gameEnded = false
    var finalScore = 0
// Game score menu
    var gameScore: SKLabelNode!
    var score: Float = 0 {
        didSet {
            gameScore.text = "Score: \(Int(score))"
        }
    }
    
    
    override func didMove(to view: SKView) {
        setBackGround()
        setInteractiveLabels()
        resetGame()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
// Clear view of existing slices
        activeSlicePoints.removeAll(keepingCapacity: true)
        
// Read the touch location
        if let touch = touches.first {
            let location = touch.location(in: self)
            activeSlicePoints.append(location)
            
// Draw the current slice
            redrawActiveSlice()
            
// Clear the node tree of slices actions
            activeSliceBG.removeAllActions()
            activeSliceFG.removeAllActions()
            
// Make the slice visible
            activeSliceBG.alpha = 1
            activeSliceFG.alpha = 1
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
// Disable if game is over
        if gameEnded {
            return
        }
// Read touch action
        guard let touch = touches.first else { return }
// Set location of touch
        let location = touch.location(in: self)
// Draw the slice
        activeSlicePoints.append(location)
        redrawActiveSlice()
// Make slice sounds
        if !isSwooshSoundActive {
            playSwooshSound()
        }
// Detect interesction of touch and bubble
        let nodesAtPoint = nodes(at: location)
        for node in nodesAtPoint {
            
// If bubble is touched then pop it
            if node.name == "bubbleRed" || node.name == "bubblePink" || node.name == "bubbleGreen" || node.name == "bubbleBlue" || node.name == "bubbleBlack" {
                let nodeName = node.name!
                
// Fire the coloured explosion animation on bubble popped
                let emitter = SKEmitterNode(fileNamed: "\(nodeName)SliceHit")!
                emitter.position = node.position
                addChild(emitter)
                
//  Check if consecutive colours were popped, apply score multiplier and show label if true
                if lastPoppedName == nodeName {
//  Add a bonus time to game timer for a same bubble popped sequence
                    gameTime += 0.5
                    pointsMultiplier = 1.5
                    multiplierLabel.alpha = 0.8
                    animateNode(multiplierLabel)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [unowned self] in
                        self.multiplierLabel.alpha = 0
                    }
                } else {
                    pointsMultiplier = 1.0
                }
// For testing
//              print("Last Bubble: \(lastPoppedName) nodeName: \(nodeName) \(pointsMultiplier)")
//  Clear bubble from view
                lastPoppedName = nodeName
                node.name = ""
                lastBubbblePopImage.removeFromParent()
// Prohibit physics interactions
                node.physicsBody?.isDynamic = false
// Animate bubble removal
                let scaleOut = SKAction.scale(to: 0.001, duration:0.2)
                let fadeOut = SKAction.fadeOut(withDuration: 0.2)
                let group = SKAction.group([scaleOut, fadeOut])
//  Run animation
                let seq = SKAction.sequence([group, SKAction.removeFromParent()])
                node.run(seq)
// Add score and set last bubble popped label
                let oldScore = score
                switch nodeName {
                case "bubbleRed":
                    score += 1 * pointsMultiplier
                    createlastBubblePop(imageName: "ballRed")
                case "bubblePink":
                    score += 2 * pointsMultiplier
                    createlastBubblePop(imageName: "ballPink")
                case "bubbleGreen":
                    score += 5 * pointsMultiplier
                    createlastBubblePop(imageName: "ballGreen")
                case "bubbleBlue":
                    score += 8 * pointsMultiplier
                    createlastBubblePop(imageName: "ballCyan")
                case "bubbleBlack":
                    score += 10 * pointsMultiplier
                    createlastBubblePop(imageName: "ballBlack")
                default:
                    score += 0
                    createlastBubblePop(imageName: "sliceLife")
                }
                
                addToScoreLabel.text = "+\(Int(score - oldScore))"
                addToScoreLabel.alpha = 0.8
                animateNode(addToScoreLabel)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [unowned self] in
                    self.addToScoreLabel.alpha = 0
                }
// Remove bubble from active bubble array
                let index = activeBubbles.index(of: node as! SKSpriteNode)!
                activeBubbles.remove(at: index)
// Play bubble popped sound effect
                run(SKAction.playSoundFileNamed("whack.caf", waitForCompletion: false))
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//  Animate slice disappearing
        activeSliceBG.run(SKAction.fadeOut(withDuration: 0.20))
        activeSliceFG.run(SKAction.fadeOut(withDuration: 0.15))
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
//  Trigger slice disappearing animation
        touchesEnded(touches, with: event)
    }
    
    override func update(_ currentTime: TimeInterval) {
// Called before each frame is rendered
        if activeBubbles.count > 0 {
            for node in activeBubbles {
//  Remove bubbles that are off the bottom of the screen from the node tree or popped
                if node.position.y < -140 {
                    node.removeAllActions()
                    if node.name == "bubbleRed" || node.name == "bubblePink" || node.name == "bubbleGreen" || node.name == "bubbleBlue" || node.name == "bubbleBlack" {
                        node.name = ""
                        node.removeFromParent()
                        if let index = activeBubbles.index(of: node) {
                            activeBubbles.remove(at: index)
                        }
                    }
                }
            }
        } else {
            if !nextSequenceQueued {
//  Throw more bubbles
                DispatchQueue.main.asyncAfter(deadline: .now() + popupTime) { [unowned self] in
                    self.tossBubbles()
                }
                nextSequenceQueued = true
            }
        }
    }
    
    func setBackGround()  {
//  Set the background
        let background = SKSpriteNode(imageNamed: "sliceBackground")
        background.position = CGPoint(x: viewWidth/2, y: viewHeight/2)
        background.blendMode = .replace
        background.zPosition = -2
        addChild(background)
    }

    func setInteractiveLabels()  {
        // Set the score multiplier
        multiplierLabel = SKLabelNode(fontNamed: "Avenir Next Condensed Bold")
        multiplierLabel.text = "1.5x"
        multiplierLabel.horizontalAlignmentMode = .center
        multiplierLabel.verticalAlignmentMode = .center
        multiplierLabel.position = CGPoint(x: viewWidth/2, y: Int(Float(viewHeight)*0.8))
        multiplierLabel.fontSize = 120
        multiplierLabel.alpha = 0
        multiplierLabel.zPosition = -1
        addChild(multiplierLabel)
        
        addToScoreLabel = SKLabelNode(fontNamed: "Avenir Next Condensed Bold")
        addToScoreLabel.horizontalAlignmentMode = .right
        addToScoreLabel.verticalAlignmentMode = .center
        addToScoreLabel.position = CGPoint(x: viewWidth - 30, y: viewHeight/2)
        addToScoreLabel.fontSize = 60
        addToScoreLabel.alpha = 0
        addToScoreLabel.zPosition = -1
        addChild(addToScoreLabel)
        
    }
    
    func createTopScore() {
        topScoreLabel = SKLabelNode(fontNamed: "Avenir Next Condensed Bold")
        topScoreLabel.text = "Top Score: \(topScore)"
        topScoreLabel.horizontalAlignmentMode = .center
        topScoreLabel.verticalAlignmentMode = .top
        topScoreLabel.position = CGPoint(x: viewWidth/2, y: viewHeight - 10)
        topScoreLabel.fontSize = 40
        topScoreLabel.alpha = 0.8
        topScoreLabel.zPosition = -1
        addChild(topScoreLabel)
    }

// Build score label
    func createScore() {
        gameScore = SKLabelNode(fontNamed: "Avenir Next Condensed Bold")
        gameScore.text = "Score: 0"
        gameScore.horizontalAlignmentMode = .left
        gameScore.verticalAlignmentMode = .bottom
        gameScore.fontSize = 48
        addChild(gameScore)
        gameScore.position = CGPoint(x: 20, y: 10)
    }

//  Create last bubble popped label
    func createlastBubblePop(imageName: String) {
        lastBubbblePopImage = SKSpriteNode(imageNamed: imageName)
        lastBubbblePopImage.position = CGPoint(x: Int(Float(viewWidth)*0.9), y: Int(Float(viewHeight)*0.95))
        addChild(lastBubbblePopImage)
    }
    
// Build timer label
    func createTimer() {
        clockLabel.text = "Time: \(timeString(time: TimeInterval(gameTime)))"
        clockLabel.horizontalAlignmentMode = .left
        clockLabel.verticalAlignmentMode = .top
        clockLabel.fontSize = 48
        addChild(clockLabel)
        clockLabel.position = CGPoint(x: 20, y: viewHeight-10)
    }
    
// Build game starting countdown timer
    func startTimer() {
        startTimerLable.text = "3"
        startTimerLable.horizontalAlignmentMode = .center
        startTimerLable.verticalAlignmentMode = .center
        startTimerLable.position = CGPoint(x: viewWidth/2, y: viewHeight/2)
        startTimerLable.fontSize = 120
        addChild(startTimerLable)
        animateNode(startTimerLable)
        startCountDown = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(updateStartTimer)), userInfo: nil, repeats: true)
    }

// Initiate and start game
    @objc func updateStartTimer() {
        if startTime == 1 {
            resetGame()
            if gameKitEnabled {
                createTopScore()
            }
            createScore()
            createlastBubblePop(imageName: "noBubblePop")
            createSlices()
            createTimer()
            startCountDown.invalidate()
            startTimerLable.removeFromParent()
            startTimerLable.removeAllActions()
            runTimer()
            tossBubbles()
        } else {
            startTime -= 1
            startTimerLable.text = "\(startTime)"
        }
        
    }

// Run the game timer
    func runTimer() {
        gameTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(updateTimer)), userInfo: nil, repeats: true)
    }
    
// Update the game timer iver seconed. If time is up stop game
    @objc func updateTimer()  {
        if gameTime < 1 {
            //Send alert to indicate time's up.
            gameTimer.invalidate()
            startTime = 3
// Move the clock to centre of screen
            clockLabel.horizontalAlignmentMode = .center
            clockLabel.verticalAlignmentMode = .center
            clockLabel.position = CGPoint(x: viewWidth/2, y: viewHeight/2)
            clockLabel.text = "Times Up!"
// Move the score to centre of screen
            gameScore.horizontalAlignmentMode = .center
            gameScore.verticalAlignmentMode = .center
            gameScore.fontSize = 80
            gameScore.position = CGPoint(x: viewWidth/2, y: Int(Float(viewHeight)/1.5))
//  Clear last bubble popped menu
            lastBubbblePopImage.removeFromParent()
            if gameKitEnabled {
                viewController.updateLeaderBoard(Int(score))
            }
//  End game
            gameEnded = true
// Go to menu
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [unowned self] in
                if self.gameKitEnabled {
                    self.topScoreLabel.removeFromParent()
                    self.topScoreLabel.removeAllActions()
                }
                self.clockLabel.removeAllActions()
                self.clockLabel.fontColor = UIColor.white
                self.gameScore.removeFromParent()
                self.score = 0.0
                self.clockLabel.removeFromParent()
                self.gameSceneDelegate?.gameOver()
                }
        } else {
            gameTime -= 1
//  Formate timer label
            if gameTime >= 60.0 {
                clockLabel.text = "Time: \(timeString(time: TimeInterval(Int(gameTime))))"
            } else {
                clockLabel.text = "Time: \(Int(gameTime))"
            }
// Animate the clock label when time is running out
            if gameTime <= 10.0 {
                clockLabel.fontColor = UIColor.red
                animateNode(clockLabel)
                istimerAnimationOn = true
            } else if istimerAnimationOn && gameTime > 10.0 {
//  Disable animation - this is only used when time is added to the game timer for score multiplier
                clockLabel.removeAllActions()
            }
//  Animate top score label if top score is achieved
            if gameKitEnabled && Int(score) > topScore {
                topScoreLabel.text = "New Top Score: \(Int(score))"
                animateNode(topScoreLabel)
            }
        }
    }
// Formate timer string if time is more than 60 seconds
    func timeString(time:TimeInterval) -> String {
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%i:%02i", minutes, seconds)
    }
    
//  Animate nodes reference: https://www.swiftbysundell.com/posts/using-spritekit-to-create-animations-in-swift
    func animateNode(_ node: SKNode) {
        node.run(.sequence([
            .repeatForever(.sequence([
                .scale(to: 1.5, duration: 0.3),
                .wait(forDuration: TimeInterval(0.2)),
                .scale(to: 1, duration: 0.3),
                .wait(forDuration: 0.2)
                ]))
            ]))
    }
    
// Create slices
    func createSlices() {
        activeSliceBG = SKShapeNode()
        activeSliceBG.zPosition = 2
        
        activeSliceFG = SKShapeNode()
        activeSliceFG.zPosition = 2
        
        activeSliceBG.strokeColor = UIColor.yellow
        activeSliceBG.lineWidth = 10
        
        activeSliceFG.strokeColor = UIColor.white
        activeSliceFG.lineWidth = 5
        
        addChild(activeSliceBG)
        addChild(activeSliceFG)
    }

//  Draw slices
    func redrawActiveSlice() {
        if activeSlicePoints.count < 2 {
            activeSliceBG.path = nil
            activeSliceFG.path = nil
            return
        }
        
        while activeSlicePoints.count > 6 {
            activeSlicePoints.remove(at: 0)
        }
        
        let path = UIBezierPath()
        path.move(to: activeSlicePoints[0])
        
        for i in 1 ..< activeSlicePoints.count {
            path.addLine(to: activeSlicePoints[i])
        }
        
        activeSliceBG.path = path.cgPath
        activeSliceFG.path = path.cgPath
    }
    
// Play slice sound effect
    func playSwooshSound() {
        isSwooshSoundActive = true
        
        let randomNumber = RandomInt(min: 1, max: 3)
        let soundName = "swoosh\(randomNumber).caf"
        
        let swooshSound = SKAction.playSoundFileNamed(soundName, waitForCompletion: true)
        
        run(swooshSound) { [unowned self] in
            self.isSwooshSoundActive = false
        }
    }

// Create bubbles and play sound effects
    func createBubbles()  {
        
        var bubble: SKSpriteNode
        
        let bubbleType = RandomDouble(min: 0, max: 99)
        
        switch bubbleType {
        case 0..<40:
            bubble = SKSpriteNode(imageNamed: "ballRed")
            run(SKAction.playSoundFileNamed("launch.caf", waitForCompletion: false))
            bubble.name = "bubbleRed"
        case 40..<70:
            bubble = SKSpriteNode(imageNamed: "ballPink")
            run(SKAction.playSoundFileNamed("launch.caf", waitForCompletion: false))
            bubble.name = "bubblePink"
        case 70..<85:
            bubble = SKSpriteNode(imageNamed: "ballGreen")
            run(SKAction.playSoundFileNamed("launch.caf", waitForCompletion: false))
            bubble.name = "bubbleGreen"
        case 85..<95:
            bubble = SKSpriteNode(imageNamed: "ballCyan")
            run(SKAction.playSoundFileNamed("launch.caf", waitForCompletion: false))
            bubble.name = "bubbleBlue"
        default:
            bubble = SKSpriteNode(imageNamed: "ballBlack")
            run(SKAction.playSoundFileNamed("launch.caf", waitForCompletion: false))
            bubble.name = "bubbleBlack"
        }
        
        addChild(bubble)
        activeBubbles.append(bubble)
        
// Randomise bubble posiion
        let randomPosition = CGPoint(x: RandomInt(min: 20, max: 1000), y: -10)
        bubble.position = randomPosition
        
// Randomise bubble angle velocity
        let randomAngularVelocity = CGFloat(RandomInt(min: -10, max: 10)) / 2.0
        var randomXVelocity = 0
        
// Randomise bubble horizontail velocity
        if randomPosition.x < 256 {
            randomXVelocity = RandomInt(min: 3, max: 10)
        } else if randomPosition.x < 512 {
            randomXVelocity = RandomInt(min: 1, max: 5)
        } else if randomPosition.x < 768 {
            randomXVelocity = -RandomInt(min: 1, max: 5)
        } else {
            randomXVelocity = -RandomInt(min: 3, max: 10)
        }
        
// Randomise bubble verticle velocity
        let randomYVelocity = RandomInt(min: 20, max: 40)
        
// Apply physics
        bubble.physicsBody = SKPhysicsBody(circleOfRadius: bubble.size.width / 2.0)
        bubble.physicsBody?.velocity = CGVector(dx: randomXVelocity * 40, dy: randomYVelocity * 40)
        bubble.physicsBody?.angularVelocity = randomAngularVelocity
        physicsBody = SKPhysicsBody(edgeLoopFrom: CGRect(x: 0, y: -300, width: viewWidth, height: viewHeight+300))
        bubble.physicsBody?.restitution = 0.2
    }
    
// Bubble sequence methods
    func maxBubbleGenerator() {
        for _ in 0...maxActiveBubbles   {
            createBubbles()
        }
    }
    
    func halfMaxBubbleGenerator() {
        for _ in 0...maxActiveBubbles   {
            createBubbles()
        }
    }
    
    func chainBubbleGenerator() {
        createBubbles()
        for _ in 0...RandomInt(min: 1, max: maxActiveBubbles) {
        DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 5.0 * RandomDouble(min: 1.0, max: 4.0))) { [unowned self] in self.createBubbles() }
        }
    }
    
    func fastChainBubbleGenerator(){
        createBubbles()
        for _ in 0...RandomInt(min: 1, max: maxActiveBubbles) {
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 10.0 * RandomDouble(min: 1.0, max: 4.0))) { [unowned self] in self.createBubbles() }
        }
    }
    
    func initialiseBubblesSequence() {
        sequence = [.one, .halfMax, .max, .chain, .fastChain]
        for _ in 0 ... 1000 {
            let nextSequence = SequenceType(rawValue: RandomInt(min: 0, max: 4))!
            sequence.append(nextSequence)
        }
    }
    
// Throw bubbles onto the view
    func tossBubbles() {
//  Diable if game is over
        if gameEnded {
            return
        }
// Increase game difficulty as game progresses
        popupTime *= 0.951
        chainDelay *= 0.9
        physicsWorld.speed *= 1.07
        gravity *= 1.015
        physicsWorld.gravity = CGVector(dx: 0, dy: gravity)
        
        let sequenceType = sequence[sequencePosition]
        
        switch sequenceType {
        case .one:
            createBubbles()
        case .halfMax:
            halfMaxBubbleGenerator()
        case .max:
            maxBubbleGenerator()
        case .chain:
            chainBubbleGenerator()
        case .fastChain:
            fastChainBubbleGenerator()
        }
        
        sequencePosition += 1
        nextSequenceQueued = false
    }
    
    func resetGame()  {
        gameEnded = false
        finalScore = 0
        physicsWorld.gravity = CGVector(dx: 0, dy: gravity)
        physicsWorld.speed = 0.5
        popupTime = 0.5
        gravity = -6.0
        chainDelay = 3.0
        initialiseBubblesSequence()
    }
    

}
