//
//  Game2.swift
//  Finder Zen 2
//
//  Created by Vince14Genius on 9/9/15.
//  Copyright © 2015 Vince14Genius. All rights reserved.
//

import SpriteKit
import AVFoundation

class Game2: SKScene, SKPhysicsContactDelegate {
    enum buttons {
        case none
        case buttonPause
    }
    
    var clickedButton = buttons.none
    
    override func didMove(to view: SKView) {
        record = standardDefaults.integer(forKey: "record2")
        maxhealth = 2
        enemyAttackCooldown = 1
        
        gameInit(self)
        
        do {
            try bgm = AVAudioPlayer(contentsOf: Bundle.main.url(forResource: "game2", withExtension: "mp3")!)
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
            case keyCodeA: leftQueue = true
            case keyCodeD: rightQueue = true
            case keyCodeLeft: leftQueue = true
            case keyCodeRight: rightQueue = true
            case keyCodeEsc: turnMenuOn()
            default: turnMenuOn()
            }
        }
    }
    
    override func keyUp(with theEvent: NSEvent) {
        let keyTyped = theEvent.keyCode
        switch keyTyped {
        case keyCodeA: leftQueue = false
        case keyCodeD: rightQueue = false
        case keyCodeLeft: leftQueue = false
        case keyCodeRight: rightQueue = false
        default: break
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        contactSort(contact)
    }
    
    override func update(_ currentTime: TimeInterval) {
        if refreshPerSecond() {
            run(.repeat(.sequence([.run({score += 1}), .wait(forDuration: 0.5)]), count: 2))
            enemyhealth -= 2
        }
        
        if refreshPerTenthSecond(currentTime) && enemyAttackCooldown == 0 {
            let randomX = CGFloat(arc4random() % 1024)
            if randomX > 256 && randomX < 768 {
                fireRed(CGPoint(x: randomX, y: 788))
            }
            var arrayList: [CGFloat] = [0, 128, 256, 384, 512, 640, 768, 896, 1024]
            for i in 1...5 {
                let r = Int(arc4random() % (9 - UInt32(i)))
                arrayList.remove(at: r)
            }
            for arrayPoint in arrayList {
                fireAndroid(fromPoint: CGPoint(x: arrayPoint, y: 788), toPoint: CGPoint(x: arrayPoint, y: -20))
            }
            
            enemyAttackCooldown = 1 / (Double(level - 1) * 0.35 + 1) //Attack Cooldown divided by Attack Speed (+35% per level)
        }
        
        refreshPerFrame(currentTime)
        childNode(withName: "Score")!.position.x = Finder.position.x
    }
}
