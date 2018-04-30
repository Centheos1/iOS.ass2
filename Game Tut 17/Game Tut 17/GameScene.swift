//
//  GameScene.swift
//  Game Tut 17
//
//  Created by Clint Sellen on 30/4/18.
//  Copyright © 2018 UTS. All rights reserved.
//

import SpriteKit
import GameplayKit

enum SequenceType: Int {
    case one, halfMax, max, chain, fastChain
}

class GameScene: SKScene {
    
    var activeSlicePoints = [CGPoint]()
    var activeSliceBG: SKShapeNode!
    var activeSliceFG: SKShapeNode!
    var isSwooshSoundActive = false
    
    var popupTime = 0.5
    var gravity = -6.0
    var sequence: [SequenceType]!
    var sequencePosition = 0
    var chainDelay = 3.0
    var nextSequenceQueued = true
    
    var activeBubbles = [SKSpriteNode]()
    var maxActiveBubbles: Int = 15
    var multiplierLabel: SKLabelNode!
    
    let startTimerLable = SKLabelNode(fontNamed: "Avenir Next Condensed Bold")
    var startCountDown: Timer!
    var startTime = 3
    
    var lastBubbblePopImageContainer = [SKSpriteNode]()
    var lastPoppedName: String = "No Popped"
    var lastBubbblePopImage: SKSpriteNode!
    var pointsMultiplier: Float = 1.0
    
    let clockLabel = SKLabelNode(fontNamed: "Avenir Next Condensed Bold")
    var gameTimer: Timer!
    var isTimerRunning = false
    var gameTime = 60
    
    var gameEnded = false
    
    var gameScore: SKLabelNode!
    var score: Float = 0 {
        didSet {
            gameScore.text = "Score: \(Int(score))"
        }
    }
    
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "sliceBackground")
        background.position = CGPoint(x: 512, y: 384)
//        background.position = CGPoint(x: 667, y: 375)
        background.blendMode = .replace
        background.zPosition = -2
        addChild(background)
        
        multiplierLabel = SKLabelNode(fontNamed: "Avenir Next Condensed Bold")
        multiplierLabel.text = "1.5x"
        multiplierLabel.horizontalAlignmentMode = .center
        multiplierLabel.verticalAlignmentMode = .center
        multiplierLabel.position = CGPoint(x: 1024/2, y: 750*0.8)
        multiplierLabel.fontSize = 120
        multiplierLabel.alpha = 0
        multiplierLabel.zPosition = -1
        addChild(multiplierLabel)
        
        physicsWorld.gravity = CGVector(dx: 0, dy: gravity)
        physicsWorld.speed = 0.5
        
//        createScore()
//        createLives()
//        createSlices()
//        createTimer()
        
        sequence = [.one, .halfMax, .max, .chain, .fastChain]
        
        for _ in 0 ... 1000 {
            let nextSequence = SequenceType(rawValue: RandomInt(min: 0, max: 4))!
            sequence.append(nextSequence)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [unowned self] in
            self.startTimer()
//            self.runTimer()
//            self.tossBubbles()
        }
    }
    
    
    func touchDown(atPoint pos : CGPoint) {
      
    }
    
    
    func touchUp(atPoint pos : CGPoint) {
       
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        // 1
        activeSlicePoints.removeAll(keepingCapacity: true)
        
        // 2
        if let touch = touches.first {
            let location = touch.location(in: self)
            activeSlicePoints.append(location)
            
            // 3
            redrawActiveSlice()
            
            // 4
            activeSliceBG.removeAllActions()
            activeSliceFG.removeAllActions()
            
            // 5
            activeSliceBG.alpha = 1
            activeSliceFG.alpha = 1
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if gameEnded {
            return
        }
        
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: self)
        
        activeSlicePoints.append(location)
        redrawActiveSlice()
    
        if !isSwooshSoundActive {
            playSwooshSound()
        }
        
        let nodesAtPoint = nodes(at: location)
        
        for node in nodesAtPoint {
            if node.name == "bubbleRed" || node.name == "bubblePink" || node.name == "bubbleGreen" || node.name == "bubbleBlue" || node.name == "bubbleBlack" {
                let nodeName = node.name!
                
                // 1
                let emitter = SKEmitterNode(fileNamed: "\(nodeName)SliceHit")!
                emitter.position = node.position
                addChild(emitter)
                
                // 2
//                if lastBubbblePopImage.name == nodeName {
                if lastPoppedName == nodeName {
                    pointsMultiplier = 1.5
                    multiplierLabel.alpha = 0.8
                    animateNode(multiplierLabel)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [unowned self] in
                        self.multiplierLabel.alpha = 0
                    }
                } else {
                    pointsMultiplier = 1.0
                }
                
                
                print("Last Bubble: \(lastPoppedName) nodeName: \(nodeName) \(pointsMultiplier)")
                
//                lastBubbblePopImage.name = nodeName
                lastPoppedName = nodeName
                node.name = ""
                lastBubbblePopImage.removeFromParent()
                // 3
                node.physicsBody?.isDynamic = false
                
                // 4
                let scaleOut = SKAction.scale(to: 0.001, duration:0.2)
                let fadeOut = SKAction.fadeOut(withDuration: 0.2)
                let group = SKAction.group([scaleOut, fadeOut])
                
                // 5
                let seq = SKAction.sequence([group, SKAction.removeFromParent()])
                node.run(seq)
                
                // 6
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
                
                // 7
                let index = activeBubbles.index(of: node as! SKSpriteNode)!
                activeBubbles.remove(at: index)
                
                // 8
                run(SKAction.playSoundFileNamed("whack.caf", waitForCompletion: false))
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        activeSliceBG.run(SKAction.fadeOut(withDuration: 0.20))
        activeSliceFG.run(SKAction.fadeOut(withDuration: 0.15))
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event)
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if activeBubbles.count > 0 {
            for node in activeBubbles {
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
                DispatchQueue.main.asyncAfter(deadline: .now() + popupTime) { [unowned self] in
                    self.tossBubbles()
                }
                
                nextSequenceQueued = true
            }
        }
    }
    
    func createScore() {
        gameScore = SKLabelNode(fontNamed: "Avenir Next Condensed Bold")
        gameScore.text = "Score: 0"
        gameScore.horizontalAlignmentMode = .left
        gameScore.verticalAlignmentMode = .bottom
        gameScore.fontSize = 48
        
        addChild(gameScore)
        
        gameScore.position = CGPoint(x: 20, y: 10)
    }
    
    func createlastBubblePop(imageName: String) {
//        for i in 0 ..< lastBubbblePopImageContainer.count {
            lastBubbblePopImage = SKSpriteNode(imageNamed: imageName)
//            lastBubbblePopImage.position = CGPoint(x: CGFloat(834 + (i * 70)), y: 720)
            lastBubbblePopImage.position = CGPoint(x: 1024*0.9, y: 712)
            addChild(lastBubbblePopImage)
//            lastBubbblePopImageContainer.append(lastBubbblePopImage)
//        }
        
//        for i in 0 ..< 3 {
//            let spriteNode = SKSpriteNode(imageNamed: "sliceLife")
//            spriteNode.position = CGPoint(x: CGFloat(834 + (i * 70)), y: 720)
//            addChild(spriteNode)
//
//            livesImages.append(spriteNode)
//        }
    }
    
    
    func createTimer() {
//        clockLabel = SKLabelNode(fontNamed: "Avenir Next Condensed Bold")
        clockLabel.text = "Time: \(timeString(time: TimeInterval(gameTime)))"
        clockLabel.horizontalAlignmentMode = .left
        clockLabel.verticalAlignmentMode = .top
        clockLabel.fontSize = 48
        addChild(clockLabel)
        
        clockLabel.position = CGPoint(x: 20, y: 740)
    }
    
    func startTimer() {
//        startTimerLable = SKLabelNode(fontNamed: "Avenir Next Condensed Bold")
        startTimerLable.text = "3"
        startTimerLable.horizontalAlignmentMode = .center
        startTimerLable.verticalAlignmentMode = .center
        startTimerLable.position = CGPoint(x: 1024/2, y: 750/2)
        startTimerLable.fontSize = 100
        addChild(startTimerLable)
        animateNode(startTimerLable)
        startCountDown = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(updateStartTimer)), userInfo: nil, repeats: true)
    }
    
    @objc func updateStartTimer() {
        if startTime == 1{
            createScore()
            createlastBubblePop(imageName: "noBubblePop")
            createSlices()
            createTimer()
            startCountDown.invalidate()
            startTimerLable.removeFromParent()
            runTimer()
            tossBubbles()
        } else {
            startTime -= 1
            startTimerLable.text = "\(startTime)"
        }
        
    }
    
    func runTimer() {
        gameTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(updateTimer)), userInfo: nil, repeats: true)
        isTimerRunning = true
    }
    
    @objc func updateTimer()  {
        if gameTime < 1 {
            //Send alert to indicate time's up.
            gameTimer.invalidate()
            clockLabel.horizontalAlignmentMode = .center
            clockLabel.verticalAlignmentMode = .center
            clockLabel.position = CGPoint(x: 1024/2, y: 750/2)
            clockLabel.text = "Times Up!"
            
            gameScore.horizontalAlignmentMode = .center
            gameScore.verticalAlignmentMode = .center
            gameScore.fontSize = 80
            gameScore.position = CGPoint(x: 1024/2, y: 750/1.5)
            
            lastBubbblePopImage.removeFromParent()
            
            gameEnded = true
            isTimerRunning = false
        } else {
            gameTime -= 1
            if gameTime >= 60 {
                clockLabel.text = "Time: \(timeString(time: TimeInterval(gameTime)))"
            } else {
                clockLabel.text = "Time: \(gameTime)"
            }
            if gameTime <= 10 {
                clockLabel.fontColor = UIColor.red
                animateNode(clockLabel)
            }
        }
    }
//    Formate timer string
    func timeString(time:TimeInterval) -> String {
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%i:%02i", minutes, seconds)
    }
    
    //  Animation function reference: https://www.swiftbysundell.com/posts/using-spritekit-to-create-animations-in-swift
    func animateNode(_ node: SKNode) {
//        for (index, node) in nodes.enumerated() {
            node.run(.sequence([
//                .wait(forDuration: TimeInterval(0.2)),
                .repeatForever(.sequence([
                    .scale(to: 1.5, duration: 0.3),
                    .wait(forDuration: TimeInterval(0.2)),
                    .scale(to: 1, duration: 0.3),
                    .wait(forDuration: 0.2)
                    ]))
                ]))
//        }
    }

    func createSlices() {
        activeSliceBG = SKShapeNode()
        activeSliceBG.zPosition = 2
        
        activeSliceFG = SKShapeNode()
        activeSliceFG.zPosition = 2
        
//        activeSliceBG.strokeColor = UIColor(red: 1, green: 0.9, blue: 0, alpha: 1)
        activeSliceBG.strokeColor = UIColor.yellow
        activeSliceBG.lineWidth = 10
        
        activeSliceFG.strokeColor = UIColor.white
        activeSliceFG.lineWidth = 5
        
        addChild(activeSliceBG)
        addChild(activeSliceFG)
    }

    func redrawActiveSlice() {
        // 1
        if activeSlicePoints.count < 2 {
            activeSliceBG.path = nil
            activeSliceFG.path = nil
            return
        }
        
        // 2
        while activeSlicePoints.count > 6 {
            activeSlicePoints.remove(at: 0)
        }
        
        // 3
        let path = UIBezierPath()
        path.move(to: activeSlicePoints[0])
        
        for i in 1 ..< activeSlicePoints.count {
            path.addLine(to: activeSlicePoints[i])
        }
        
        // 4
        activeSliceBG.path = path.cgPath
        activeSliceFG.path = path.cgPath
    }

    func playSwooshSound() {
        isSwooshSoundActive = true
        
        let randomNumber = RandomInt(min: 1, max: 3)
        let soundName = "swoosh\(randomNumber).caf"
        
        let swooshSound = SKAction.playSoundFileNamed(soundName, waitForCompletion: true)
        
        run(swooshSound) { [unowned self] in
            self.isSwooshSoundActive = false
        }
    }
    
    func createBubbles()  {
        
        var bubble: SKSpriteNode
        
        let bubbleType = RandomDouble(min: 1, max: 100)
        
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
        
        // 1
        let randomPosition = CGPoint(x: RandomInt(min: 64, max: 960), y: -128)
        bubble.position = randomPosition
        
        // 2
        let randomAngularVelocity = CGFloat(RandomInt(min: -6, max: 6)) / 2.0
        var randomXVelocity = 0
        
        // 3
        if randomPosition.x < 256 {
            randomXVelocity = RandomInt(min: 8, max: 15)
        } else if randomPosition.x < 512 {
            randomXVelocity = RandomInt(min: 3, max: 5)
        } else if randomPosition.x < 768 {
            randomXVelocity = -RandomInt(min: 3, max: 5)
        } else {
            randomXVelocity = -RandomInt(min: 8, max: 15)
        }
        
        // 4
        let randomYVelocity = RandomInt(min: 24, max: 32)
        
        // 5
        bubble.physicsBody = SKPhysicsBody(circleOfRadius: bubble.size.width / 2.0)
        bubble.physicsBody?.velocity = CGVector(dx: randomXVelocity * 40, dy: randomYVelocity * 40)
        bubble.physicsBody?.angularVelocity = randomAngularVelocity
        physicsBody = SKPhysicsBody(edgeLoopFrom: CGRect(x: 0, y: -300, width: 1024, height: 1050))
//        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
//        bubble?.collisionBitMask = 0
    }
    
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
    
    func tossBubbles() {
        if gameEnded {
            return
        }
        
        popupTime *= 0.951
        chainDelay *= 0.9
        physicsWorld.speed *= 1.05
        gravity *= 1.01
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
    
    func endGame(triggeredByBomb: Bool) {
        if gameEnded {
            return
        }
        
        gameEnded = true
        physicsWorld.speed = 0
        isUserInteractionEnabled = false
    }

}
