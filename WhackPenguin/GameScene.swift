//
//  GameScene.swift
//  WhackPenguin
//
//  Created by Phat Nguyen on 27/10/2021.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    var numRounds = 0
    var gameOver: SKSpriteNode!
    var restartBtn: SKLabelNode!
    var gameScore: SKLabelNode!
    var scores = 0 {
        didSet {
            gameScore.text = "Scores: \(scores)"
        }
    }
    var slots = [WhackHole]()
    var popupTime = 0.85
    
    override func didMove(to view: SKView) {
        // setup screen
        createScreen()
    }
        
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {return}
        let location = touch.location(in: self)
        let tappedNodes = nodes(at: location)
        
        if self.restartBtn != nil {
            if tappedNodes.contains(self.restartBtn) {
                restartFn()
            }
        }
        
        for node in tappedNodes {
            guard let whackHole = node.parent?.parent as? WhackHole else {continue}
            if !whackHole.isVisible { continue }
            if whackHole.isHit { continue }
            whackHole.hit()
            
            whackHole.charNode.xScale = 0.85
            whackHole.charNode.yScale = 0.85
            
            if node.name == "charFriend" {
                scores -= 5
                run(SKAction.playSoundFileNamed("whackBad.caf", waitForCompletion: false))
            } else if node.name == "charEnemy" {
                scores += 1
                run(SKAction.playSoundFileNamed("whack.caf", waitForCompletion: false))
            }
        }
    }
    
    func createSlot(at position: CGPoint) {
        let slot = WhackHole()
        slot.configure(at: position)
        addChild(slot)
        slots.append(slot)
    }
    
    func createScreen() {
        // backgroud
        let background = SKSpriteNode(imageNamed: "whackBackground")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        // scores Label
        gameScore = SKLabelNode(fontNamed: "Chalkduster")
        gameScore.text = "Scores: 0"
        gameScore.position = CGPoint(x: 8, y: 8)
        gameScore.horizontalAlignmentMode = .left
        gameScore.fontSize = 48
        addChild(gameScore)
        
        // create Slot hole
        for i in 0 ..< 5 { createSlot(at: CGPoint(x: 100 + (i * 170), y: 410)) }
        for i in 0 ..< 4 { createSlot(at: CGPoint(x: 180 + (i * 170), y: 320)) }
        for i in 0 ..< 5 { createSlot(at: CGPoint(x: 100 + (i * 170), y: 230)) }
        for i in 0 ..< 4 { createSlot(at: CGPoint(x: 180 + (i * 170), y: 140)) }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            [weak self] in self?.createEnemy()
        }
    }
    
    func createEnemy() {
        numRounds += 1
        
        if numRounds >= 30 {
            for slot in slots {
                slot.hide()
            }
            
            gameOver = SKSpriteNode(imageNamed: "gameOver")
            gameOver.position = CGPoint(x: 512, y: 384)
            gameOver.zPosition = 1
            addChild(gameOver)
            
            restartBtn = SKLabelNode(fontNamed: "Chalkduster")
            restartBtn.text = "Restart"
            restartBtn.name = "restart"
            restartBtn.position = CGPoint(x: 512, y: 200)
            restartBtn.zPosition = 1
            addChild(restartBtn)
            
            return
        }
        
        popupTime *= 0.991
        
        slots.shuffle()
        slots[0].show(hideTime: popupTime)
        
        if Int.random(in: 0...12) > 4 { slots[1].show(hideTime: popupTime) }
            if Int.random(in: 0...12) > 8 {  slots[2].show(hideTime: popupTime) }
            if Int.random(in: 0...12) > 10 { slots[3].show(hideTime: popupTime) }
            if Int.random(in: 0...12) > 11 { slots[4].show(hideTime: popupTime)  }
        
        let minDelay = popupTime / 2.0
        let maxDelay = popupTime * 2
        let delay = Double.random(in: minDelay...maxDelay)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            [weak self] in self?.createEnemy()
        }
    }
    
    func restartFn() {
        removeChildren(in: [gameOver, restartBtn])
        numRounds = 0
        scores = 0
        createEnemy()
    }
}
