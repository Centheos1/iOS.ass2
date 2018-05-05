//
//  GameViewController.swift
//  Game Tut 17
//
//  Created by Clint Sellen on 30/4/18.
//  Copyright © 2018 UTS. All rights reserved.
//
//  references:
//  https://forums.macrumors.com/threads/problem-with-gamecenter-leaderboards.1829730/

import UIKit
import SpriteKit
import GameplayKit
import GameKit


class GameViewController: UIViewController, GameSceneDelegate, GKGameCenterControllerDelegate {
    
    var currentGame: GameScene!
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var maxBubbleCountSlider: UISlider!
    @IBOutlet weak var gameTimerSlider: UISlider!
    @IBOutlet weak var maxBubbleCountLabel: UILabel!
    @IBOutlet weak var gameTimerLabel: UILabel!
    
//  GameKit Variables
// Check if the user has Game Center enabled
    var gcEnabled = Bool()
// Check the default leaderboardID
    var gcDefaultLeaderBoard = String()
    var displayName = String()
    let localPlayer: GKLocalPlayer = GKLocalPlayer.localPlayer()
// Define leader board
//    let LEADERBOARD_ID = "com.score.bubbleNinja"
// - My 3 year old son has the best score and its too hard to beat in simulator. I leave the test score board for demonstration
    let LEADERBOARD_ID = "com.score.bubbleNinjaTest"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
// Call the Game Center authentication controller
        authenticateLocalPlayer()
        menuView.isHidden = false
        
        if let view = self.view as! SKView? {
// Load the SKScene from 'GameScene.sks'
            if let scene = GameScene(fileNamed: "GameScene") {
// Change the scale mode depending on the device. Best use is for iPad but will word on iPhone
                if UIDevice.current.userInterfaceIdiom == .pad {
// for testing
//                    print("iPad")
                    scene.scaleMode = .aspectFill
                } else if UIDevice.current.userInterfaceIdiom == .phone {
// for testing
//                    print("iPhone")
                    scene.scaleMode = .fill
                }
// Present the scene
                view.presentScene(scene)
                currentGame = scene //as! GameScene
                currentGame.viewController = self
                currentGame.gameSceneDelegate = self
            }
            view.ignoresSiblingOrder = true
//  Show the node tree information
            view.showsFPS = false
            view.showsNodeCount = false
        }
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
// Authenticate Local Player
    func authenticateLocalPlayer() {
        localPlayer.authenticateHandler = {(ViewController, error) -> Void in
            if((ViewController) != nil) {
                self.present(ViewController!, animated: true, completion: nil)
            } else if (self.localPlayer.isAuthenticated) {
// Player is already authenticated & logged in, load game center
                self.gcEnabled = true            
// Get the default leaderboard ID
                self.localPlayer.loadDefaultLeaderboardIdentifier(completionHandler: { (leaderboardIdentifer, error) in
                if error != nil { print(error!)
                } else { self.gcDefaultLeaderBoard = leaderboardIdentifer! }
                })
                
                if self.localPlayer.displayName != nil {
                    self.displayName = self.localPlayer.displayName!
                }
            } else {
// Game center is not enabled on the users device, no leader board or top score will be displayed
                self.gcEnabled = false
                print("Local player could not be authenticated!")
                if error != nil {
                    print(error!)
                }
            }
        }
    }
    
    @IBAction func playGame(_ sender: UIButton) {
        currentGame.gameTime = Double(gameTimerSlider.value)
        currentGame.maxActiveBubbles = Int(maxBubbleCountSlider.value)
        menuView.isHidden = true
        currentGame.startTimer()
        if gcEnabled {
            getBestScore()
            currentGame.gameKitEnabled = true
        } else {
            currentGame.gameKitEnabled = false
        }
    }
    
    @IBAction func maxBubleCountChanged(_ sender: Any) {
        maxBubbleCountLabel.text = "Maximum Bubble Count = \(Int(maxBubbleCountSlider.value))"
    }
    
    @IBAction func gameTimerChanged(_ sender: Any) {
        gameTimerLabel.text = "Game Time = \(Int(gameTimerSlider.value))"
    }
    
//  Open Game Center Leader Board
    @IBAction func checkGCLeaderboard(_ sender: AnyObject) {
        let gcVC = GKGameCenterViewController()
        gcVC.gameCenterDelegate = self
        gcVC.viewState = .leaderboards
        gcVC.leaderboardIdentifier = LEADERBOARD_ID
        present(gcVC, animated: true, completion: nil)
    }
    
// Delegate to dismiss the GC controller
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
    
//  Game scene passes to this function at the end of a game
    func gameOver() {
//  for testing
//        print("Inside of gameOver()")
        menuView.isHidden = false
// Submit score to GC leaderboard
        if gcEnabled {
            showScoreBoard()
        } 
    }
    
    func showScoreBoard() {
// Present Leader board
        let gcVC = GKGameCenterViewController()
        gcVC.gameCenterDelegate = self
        gcVC.viewState = .leaderboards
        gcVC.leaderboardIdentifier = LEADERBOARD_ID
        present(gcVC, animated: true, completion: nil)
    }
    
    func updateLeaderBoard(_ score: Int) {
//  for testing
//        print("updateLeaderBoard() score: \(score)")
        let bestScoreInt = GKScore(leaderboardIdentifier: LEADERBOARD_ID)
        bestScoreInt.value = Int64(score)
        GKScore.report([bestScoreInt]) { (error) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
//  for testing
//                print("Best Score submitted to your Leaderboard!")
            }
        }
    }
    
    func getBestScore() {
//  get the best score from the leader board
        let leaderBoardRequest = GKLeaderboard()
        leaderBoardRequest.identifier = LEADERBOARD_ID
        leaderBoardRequest.playerScope = GKLeaderboardPlayerScope.global
        leaderBoardRequest.timeScope = GKLeaderboardTimeScope.allTime
        leaderBoardRequest.loadScores(completionHandler: { (score, error) in
            if error != nil { print(error!)
            } else if score != nil {
                if let topScore = leaderBoardRequest.scores?.first?.value {
// for testing
//                    print("\rBestScore: \(topScore)")
                    self.currentGame.topScore = Int(topScore)
                }
            }
        })
    }
}
