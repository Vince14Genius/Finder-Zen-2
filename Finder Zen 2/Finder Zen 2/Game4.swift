//
//  Game4.swift
//  Finder Zen 2
//
//  Created by Vince14Genius on 9/9/15.
//  Copyright © 2015 Vince14Genius. All rights reserved.
//

import SpriteKit
import AVFoundation

class Game4: SKScene, SKPhysicsContactDelegate {
    enum buttons {
        case none
        case buttonPause
    }
    
    var clickedButton = buttons.none
    
    func massacreChild(_ destination: CGPoint) {
        let projectile = SKSpriteNode(imageNamed: "BallRed")
        projectile.zPosition = 3
        projectile.position = childNode(withName: "Boss")!.position
        projectile.physicsBody = projectilePhysicsBody(contactBitMask_Red)
        childNode(withName: "Hostiles")!.addChild(projectile)
        
        let offset = CGPointsSubtract(destination, projectile.position)
        let direction = CGPointsNormalize(offset)
        let shootAmount = CGPointsMultiply(direction, 1000)
        projectile.run(.sequence([shootSoundAction, .move(to: CGPointsAdd(projectile.position, shootAmount), duration: 6.4 - addedDifficulty * 1.6), .removeFromParent()]))
    }
    
    func massacre() {
        var points = [
            CGPoint(x: -80, y: -80),
            CGPoint( x: 80,  y: 80),
            CGPoint( x: 80, y: -80),
            CGPoint(x: -80,  y: 80),
            CGPoint(x: -80,   y: 0),
            CGPoint( x: 80,   y: 0),
            CGPoint(  x: 0, y: -80),
            CGPoint(  x: 0,  y: 80),
        ]
        let randomExile = Int(arc4random() % 4) + 1
        points.remove(at: randomExile * 2 - 1)
        points.remove(at: randomExile * 2 - 2)
        
        for point in points {
            massacreChild(CGPointsAdd(point, CGPoint(x: 512, y: 384)))
        }
    }
    
    override func didMove(to view: SKView) {
        childNode(withName: "Boss")!.physicsBody = SKPhysicsBody(circleOfRadius: 64)
        childNode(withName: "Boss")!.physicsBody!.isDynamic = false
        childNode(withName: "Boss")!.physicsBody!.allowsRotation = false
        childNode(withName: "Boss")!.physicsBody!.pinned = true
        childNode(withName: "Finder")!.physicsBody!.contactTestBitMask = contactBitMask_Finder
        childNode(withName: "Boss")!.physicsBody!.contactTestBitMask = contactBitMask_Enemy
        record = standardDefaults.integer(forKey: "record4")
        maxhealth = 8
        
        enemyAttackCooldown = 1
        
        gameInit(self)
        
        do {
            try bgm = AVAudioPlayer(contentsOf: Bundle.main.url(forResource: "game4", withExtension: "mp3")!)
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
            case keyCodeA: leftQueue = true
            case keyCodeD: rightQueue = true
            case keyCodeLeft: leftQueue = true
            case keyCodeRight: rightQueue = true
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
            let j = arc4random() % 2
            if j == 0 {
                run(.repeat(.sequence([.run({
                    firePurple(self.childNode(withName: "Boss")!.position)
                }), .wait(forDuration: 0.1)]), count: 6))
            }
            enemyhealth += 1
            if score > (level - 1) * 100 {
                score -= 1
            }
        }
        
        if refreshPerTenthSecond(currentTime) && enemyAttackCooldown == 0 {
            let k = arc4random() % 10
            if k == 0 {
                massacre()
            }
            if k > 3 {
                fireAndroid(fromPoint: ballRand(), toPoint: childNode(withName: "Boss")!.position)
            }
            
            enemyAttackCooldown = 1 / (Double(level - 1) * 0.1 + 1) //Attack Cooldown divided by Attack Speed (+10% per level)
        }
        
        refreshPerFrame(currentTime)
        
        let offset = CGPointsSubtract(Finder.position, CGPoint(x: 512, y: 384))
        let direction = CGPointsNormalize(offset)
        let shootAmount = CGPointsMultiply(direction, 320)
        Finder.position = CGPointsAdd(CGPoint(x: 512, y: 384), shootAmount)
    }
}
