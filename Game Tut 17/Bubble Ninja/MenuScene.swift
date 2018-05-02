//
//  MenuScene.swift
//  Game Tut 17
//
//  Created by Clint Sellen on 2/5/18.
//  Copyright © 2018 UTS. All rights reserved.
//

import SpriteKit

class MenuScene: SKScene {
    
    // View Parameters
    let viewWidth = 1024
    let viewHeight = 750
    var label = SKLabelNode(fontNamed: "Avenir Next Condensed Bold")
    
    override func didMove(to view: SKView) {
        //  Set the background
        let background = SKSpriteNode(imageNamed: "sliceBackground")
        background.position = CGPoint(x: viewWidth/2, y: viewHeight/2)
        background.blendMode = .replace
        background.zPosition = -2
        addChild(background)
    
    
        label.text = "Menu Screen"
        label.position = CGPoint(x: 500, y: 500)        
        label.fontSize = 100
        addChild(label)
    }
}
