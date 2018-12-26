//
//  Game3.swift
//  Finder Zen 2
//
//  Created by Vince14Genius on 9/9/15.
//  Copyright © 2015 Vince14Genius. All rights reserved.
//

import SpriteKit
import AVFoundation

class Game3: SKScene, SKPhysicsContactDelegate {
    enum buttons {
        case none
        case buttonPause
    }
    
    var clickedButton = buttons.none
    
    override func didMove(to view: SKView) {
        childNode(withName: "Terminal")!.physicsBody!.contactTestBitMask = contactBitMask_Enemy
        record = standardDefaults.integer(forKey: "record3")
        maxhealth = 4
        enemyAttackCooldown = 1
        
        gameInit(self)
        
        do {
            try bgm = AVAudioPlayer(contentsOf: Bundle.main.url(forResource: "game3", withExtension: "mp3")!)
        } catch {
            fatalError("Failed to load AVAudioPlayer")
        }
        bgm.volume = 1
    }
    
    func enemyMovement() {
        childNode(withName: "Terminal")!.run(.moveTo(y: CGFloat(arc4random() % 768), duration: 1.5))
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
                if leftQueue || rightQueue || upQueue || downQueue  {
                    fireCyan(point)
                } else {
                    fireBlue(point)
                }
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
            case keyCodeW: upQueue = true
            case keyCodeS: downQueue = true
            case keyCodeUp: upQueue = true
            case keyCodeDown: downQueue = true
            case keyCodeEsc: turnMenuOn()
            default: turnMenuOn()
            }
        }
    }
    
    override func keyUp(with theEvent: NSEvent) {
        let keyTyped = theEvent.keyCode
        switch keyTyped {
        case keyCodeW: upQueue = false
        case keyCodeS: downQueue = false
        case keyCodeUp: upQueue = false
        case keyCodeDown: downQueue = false
        default: break
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        contactSort(contact)
    }
    
    override func update(_ currentTime: TimeInterval) {
        _ = refreshPerSecond()
        
        if refreshPerTenthSecond(currentTime) {
            let j = arc4random() % 5
            switch j {
            case 0...1:
                firePurple(childNode(withName: "Terminal")!.position)
                enemyMovement()
            default: break
            }
            
            if enemyAttackCooldown == 0 {
                let k = arc4random() % 2
                if k == 0 {
                    fireRed(childNode(withName: "Terminal")!.position)
                }
                
                enemyAttackCooldown = 1 / (Double(level - 1) * 0.5 + 1) //Attack Cooldown divided by Attack Speed (+50% per level)
            }
        }
        
        refreshPerFrame(currentTime)
        
        /*
        if childNode(withName: "Terminal")!.position.y > 680 {
            childNode(withName: "//BaseEnemy")!.position.y = -75
        } else {
            childNode(withName: "//BaseEnemy")!.position.y = 75
        }
        */
    }
}
