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
    var gcEnabled = Bool() // Check if the user has Game Center enabled
    var gcDefaultLeaderBoard = String() // Check the default leaderboardID
    var displayName = String()
    let localPlayer: GKLocalPlayer = GKLocalPlayer.localPlayer()
// Define leader board
    let LEADERBOARD_ID = "com.score.bubbleNinja"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
// Call the Game Center authentication controller
        authenticateLocalPlayer()
        
        menuView.isHidden = false
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = GameScene(fileNamed: "GameScene") {
                
                if UIDevice.current.userInterfaceIdiom == .pad {
                    print("iPad")
//                    scene.size.height = 1024
//                    scene.size.width = 750
//                    scene.viewWidth = 1024
//                    scene.viewHeight = 750
                    scene.scaleMode = .aspectFill
                } else if UIDevice.current.userInterfaceIdiom == .phone {
                    print("iPhone")
//                    scene.size.height = 667
//                    scene.size.width = 375
//                    scene.viewWidth = 667
//                    scene.viewHeight = 375
                  scene.scaleMode = .fill
                }
//                scene.viewHeight = Int(view.bounds.height)
//                scene.viewWidth = Int(view.bounds.width)
                // Set the scale mode to scale to fit the window
//                scene.scaleMode = .aspectFill
//                scene.scaleMode = .fill
//                scene.gameSceneDelegate = self
                // Present the scene
                view.presentScene(scene)
                currentGame = scene //as! GameScene
                currentGame.viewController = self
                currentGame.gameSceneDelegate = self
            }
            view.ignoresSiblingOrder = true

            view.showsFPS = false
            view.showsNodeCount = false
        }
    }
    
    // MARK: - AUTHENTICATE LOCAL PLAYER
    func authenticateLocalPlayer() {
//        let localPlayer: GKLocalPlayer = GKLocalPlayer.localPlayer()
        
        localPlayer.authenticateHandler = {(ViewController, error) -> Void in
            if((ViewController) != nil) {
                // 1. Show login if player is not logged in
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
// Game center is not enabled on the users device
                self.gcEnabled = false
                print("Local player could not be authenticated!")
                if error != nil {
                    print(error!)
                }
            }
        }
    }

// SUBMIT THE UPDATED SCORE TO GAME CENTER
//    @IBAction func addScoreAndSubmitToGC(_ sender: AnyObject) {
//        // Add 10 points to current score
////        scoreLabel.text = "\(score)"
////        nameLabel.text = displayName
//        // Submit score to GC leaderboard
//        let bestScoreInt = GKScore(leaderboardIdentifier: LEADERBOARD_ID)
////        bestScoreInt.value = Int64(score)
//        GKScore.report([bestScoreInt]) { (error) in
//            if error != nil {
//                print(error!.localizedDescription)
//            } else {
//                print("Best Score submitted to your Leaderboard!")
//            }
//        }
//    }
    
    @IBAction func playGame(_ sender: UIButton) {
        currentGame.gameTime = Int(gameTimerSlider.value)
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
    
    
    // MARK: - OPEN GAME CENTER LEADERBOARD
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
    
    func gameOver() {
        print("Inside of gameOver()")
        menuView.isHidden = false
// Submit score to GC leaderboard
        if gcEnabled {
            let bestScoreInt = GKScore(leaderboardIdentifier: LEADERBOARD_ID)
            bestScoreInt.value = Int64(currentGame.finalScore)
            GKScore.report([bestScoreInt]) { (error) in
                if error != nil {
                    print(error!.localizedDescription)
                } else {
                    print("Best Score submitted to your Leaderboard!")
                }
            }
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
    
    func loadScores(completionHandler: (([GKScore]?, Error?) -> Void)? = nil) {
        
    }
    
    func loadLeaderboards(completionHandler: (([GKLeaderboard]?, Error?) -> Void)? = nil) {
        
    }
    
    func getBestScore() {
        
        let leaderBoardRequest = GKLeaderboard()
        leaderBoardRequest.identifier = LEADERBOARD_ID
        leaderBoardRequest.playerScope = GKLeaderboardPlayerScope.global
        leaderBoardRequest.timeScope = GKLeaderboardTimeScope.allTime
        
        leaderBoardRequest.loadScores(completionHandler: { (score, error) in
            if error != nil { print(error!)
            } else if score != nil {
                if let topScore = leaderBoardRequest.scores?.first?.value {
                    print("\rBestScore: \(topScore)")
                    self.currentGame.topScore = Int(topScore)
                }
            }
        })
        
    }
}
