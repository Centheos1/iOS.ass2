//
//  GameViewController.swift
//  Game Tut 17
//
//  Created by Clint Sellen on 30/4/18.
//  Copyright © 2018 UTS. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import GameKit


class GameViewController: UIViewController, GameSceneDelegate, GKGameCenterControllerDelegate {
    
    var currentGame: GameScene!
    
//  GameKit Variables
    var gcEnabled = Bool() // Check if the user has Game Center enabled
    var gcDefaultLeaderBoard = String() // Check the default leaderboardID
    var displayName = String()
    
// Define leader board
    let LEADERBOARD_ID = "com.score.bubbleNinja"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
// Call the Game Center authentication controller
//        authenticateLocalPlayer()
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = GameScene(fileNamed: "GameScene") {
                
//                if UIDevice.current.userInterfaceIdiom == .pad {
//                    print("iPad")
//                    scene.viewWidth = 1024
//                    scene.viewHeight = 750
//                } else if UIDevice.current.userInterfaceIdiom == .phone {
//                    print("iPhone")
//                    scene.viewWidth = 667
//                    scene.viewHeight = 375
//                }
//                scene.viewHeight = Int(view.bounds.height)
//                scene.viewWidth = Int(view.bounds.width)
                // Set the scale mode to scale to fit the window
//                scene.scaleMode = .aspectFill
                scene.scaleMode = .fill
//                scene.gameSceneDelegate = self
                // Present the scene
                view.presentScene(scene)
                currentGame = scene //as! GameScene
                currentGame.viewController = self
                currentGame.gameSceneDelegate = self
            }
            view.ignoresSiblingOrder = true

            view.showsFPS = true
            view.showsNodeCount = true
        }
    }
    
    // MARK: - AUTHENTICATE LOCAL PLAYER
    func authenticateLocalPlayer() {
        let localPlayer: GKLocalPlayer = GKLocalPlayer.localPlayer()
        
        localPlayer.authenticateHandler = {(ViewController, error) -> Void in
            if((ViewController) != nil) {
                // 1. Show login if player is not logged in
                self.present(ViewController!, animated: true, completion: nil)
            } else if (localPlayer.isAuthenticated) {
                // 2. Player is already authenticated & logged in, load game center
                self.gcEnabled = true
                
                // Get the default leaderboard ID
                localPlayer.loadDefaultLeaderboardIdentifier(completionHandler: { (leaderboardIdentifer, error) in
                    if error != nil { print(error!)
                    } else { self.gcDefaultLeaderBoard = leaderboardIdentifer! }
                })
                
                if localPlayer.displayName != nil {
                    self.displayName = localPlayer.displayName!
                }
                
            } else {
                // 3. Game center is not enabled on the users device
                self.gcEnabled = false
                print("Local player could not be authenticated!")
                if error != nil {
                    print(error!)
                }
            }
        }
    }

    // MARK: - ADD 10 POINTS TO THE SCORE AND SUBMIT THE UPDATED SCORE TO GAME CENTER
    @IBAction func addScoreAndSubmitToGC(_ sender: AnyObject) {
        // Add 10 points to current score
//        scoreLabel.text = "\(score)"
//        nameLabel.text = displayName
        // Submit score to GC leaderboard
        let bestScoreInt = GKScore(leaderboardIdentifier: LEADERBOARD_ID)
//        bestScoreInt.value = Int64(score)
        GKScore.report([bestScoreInt]) { (error) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                print("Best Score submitted to your Leaderboard!")
            }
        }
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
// Submit score to GC leaderboard
//        let bestScoreInt = GKScore(leaderboardIdentifier: LEADERBOARD_ID)
//        //        bestScoreInt.value = Int64(score)
//        GKScore.report([bestScoreInt]) { (error) in
//            if error != nil {
//                print(error!.localizedDescription)
//            } else {
//                print("Best Score submitted to your Leaderboard!")
//            }
//        }
//// Present Leader board
//        let gcVC = GKGameCenterViewController()
//        gcVC.gameCenterDelegate = self
//        gcVC.viewState = .leaderboards
//        gcVC.leaderboardIdentifier = LEADERBOARD_ID
//        present(gcVC, animated: true, completion: nil)
    }
//    What happens now???
}
