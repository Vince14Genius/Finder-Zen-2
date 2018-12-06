//
//  Game1.swift
//  Finder Zen 2
//
//  Created by Vince14Genius on 9/9/15.
//  Copyright © 2015 Vince14Genius. All rights reserved.
//

import SpriteKit
import AVFoundation

class Game1: SKScene, SKPhysicsContactDelegate {
    enum buttons {
        case none
        case buttonPause
    }
    
    var clickedButton = buttons.none
    
    override func didMove(to view: SKView) {
        record = standardDefaults.integer(forKey: "record1")
        maxhealth = 1
        
        gameInit(self)
        
        do {
            try bgm = AVAudioPlayer(contentsOf: Bundle.main.url(forResource: "game1", withExtension: "mp3")!)
        } catch {
            fatalError("Failed to load AVAudioPlayer")
        }
        bgm.volume = 1
    }
    
    override func mouseDown(with theEvent: NSEvent) {
        let point = theEvent.location(in: self)
        let clickedNode = atPoint(point)
        
        attackPoint = nil
        
        if menuOn {
            menuInputBegan(clickedNode)
        } else {
            clickedButton = .none
            
            if clickedNode === childNode(withName: "ButtonPause") {
                clickedButton = .buttonPause
                childNode(withName: "ButtonPause")!.alpha = 0.5
            } else {
                fireBlue(point)
                attackPoint = point
            }
        }
    }
    
    override func mouseDragged(with theEvent: NSEvent) {
        if !menuOn {
            if attackPoint != nil {
                attackPoint = theEvent.location(in: self)
            }
        }
    }
    
    override func mouseUp(with theEvent: NSEvent) {
        let point = theEvent.location(in: self)
        let clickedNode = atPoint(point)
        
        attackPoint = nil
        
        if menuOn {
            menuInputEnded(clickedNode)
        } else {
            if clickedNode === childNode(withName: "ButtonPause") && clickedButton == .buttonPause {
                turnMenuOn()
            }
            
            clickedButton = .none
            childNode(withName: "ButtonPause")!.alpha = 1
        }
    }
    
    override func keyDown(with theEvent: NSEvent) {
        if !menuOn {
            let keyTyped = theEvent.keyCode
            switch keyTyped {
            case keyCodeEsc: turnMenuOn()
            default: turnMenuOn()
            }
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        contactSort(contact)
    }
    
    override func update(_ currentTime: TimeInterval) {
        if refreshPerSecond() {
            fireAndroid(fromPoint: ballRand(), toPoint: childNode(withName: "Finder")!.position)
        }
        
        _ = refreshPerTenthSecond(currentTime)
        refreshPerFrame(currentTime)
    }
    
}
