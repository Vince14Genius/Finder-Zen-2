//
//  GameSharedFunctions.swift
//  Finder Zen 2
//
//  Created by Vince14Genius on 9/16/15.
//  Copyright © 2015 Vince14Genius. All rights reserved.
//

import SpriteKit
import AVFoundation

var adventureModeOn = false
var menuOn = false
var timeElapsed: TimeInterval = 0.0
var addedDifficulty = 0.0

var level = 1
var score = 0
var record = 0
var maxhealth = 1
var health = 10
var enemyhealth = 100
var attackCooldown: TimeInterval = 0
var alternateAttackCooldown: TimeInterval = 0
var velocityX: CGFloat = 0
var velocityY: CGFloat = 0
var enemyAttackCooldown: TimeInterval = 0

var oldHealth = 10
var oldEnemyHealth = 100
var oldTime = 0
var lastSpawnTime: TimeInterval = 0

var leftQueue = false
var rightQueue = false
var upQueue = false
var downQueue = false

var attackPoint: CGPoint?

var oldFrameScore = "0" //Used to protect the score from cheats.

let standardDefaults = UserDefaults.standard
var currentScene = SKScene()
var Finder = SKNode()
var Hostiles = SKNode()
var Projectiles = SKNode()
var Effects = SKNode()

let shootSoundAction = SKAction.playSoundFileNamed("shoot.mp3", waitForCompletion: false)

let contactBitMask_Finder : UInt32 =        0b1
let contactBitMask_Android: UInt32 =       0b10
let contactBitMask_Enemy  : UInt32 =      0b100
let contactBitMask_Blue   : UInt32 =     0b1000
let contactBitMask_Cyan   : UInt32 =    0b10000
let contactBitMask_Red    : UInt32 =   0b100000
let contactBitMask_Purple : UInt32 =  0b1000000
let contactBitMask_Green  : UInt32 = 0b10000000

let keyCodeEsc: UInt16 = 53
let keyCodeA: UInt16 = 0
let keyCodeS: UInt16 = 1
let keyCodeD: UInt16 = 2
let keyCodeW: UInt16 = 13
let keyCodeLeft: UInt16 = 123
let keyCodeRight: UInt16 = 124
let keyCodeDown: UInt16 = 125
let keyCodeUp: UInt16 = 126

func CGPointsAdd(_ a: CGPoint, _ b: CGPoint) -> CGPoint {
    return CGPoint(x: a.x + b.x, y: a.y + b.y)
}

func CGPointsSubtract(_ a: CGPoint, _ b: CGPoint) -> CGPoint {
    return CGPoint(x: a.x - b.x, y: a.y - b.y)
}

func CGPointsMultiply(_ a: CGPoint, _ b: CGFloat) -> CGPoint {
    return CGPoint(x: a.x * b, y: a.y * b)
}

func CGPointsNormalize(_ a: CGPoint) -> CGPoint {
    let length = CGFloat(sqrtf(Float(a.x * a.x + a.y * a.y)));
    return CGPoint(x: a.x / length, y: a.y / length)
}

func shootAtDirection(_ a: CGPoint, _ b: CGPoint) -> CGPoint {
    return CGPointsAdd(b, CGPointsMultiply(CGPointsNormalize(CGPointsSubtract(a, b)), 2000))
}

//This function sets up general stuff at the start of each game. 

func gameInit(_ scene: SKScene) {
    currentScene = scene
    Finder = scene.childNode(withName: "Finder")!
    Hostiles = scene.childNode(withName: "Hostiles")!
    Projectiles = scene.childNode(withName: "Projectiles")!
    Effects = scene.childNode(withName: "Effects")!
    
    localizeLabelsInScene(currentScene)
    scene.physicsWorld.contactDelegate = (scene as! SKPhysicsContactDelegate)
    scene.childNode(withName: "Finder")!.physicsBody!.contactTestBitMask = contactBitMask_Finder
    (Effects as! SKReferenceNode).resolve()
    
    level = 1
    score = 0
    health = maxhealth
    enemyhealth = 100
    attackCooldown = 0
    alternateAttackCooldown = 0
    velocityX = 0
    velocityY = 0

    lastSpawnTime = 0
    oldTime = 0
    oldHealth = health
    oldEnemyHealth = enemyhealth
    
    leftQueue = false
    rightQueue = false
    upQueue = false
    downQueue = false
    
    attackPoint = nil
    
    oldFrameScore = "0"
    
    timeElapsed = 0
    addedDifficulty = 0
    
    menuOn = false
    
    if adventureModeOn {
        currentScene.childNode(withName: "Score")!.isHidden = true
    }
}

//This function provides the position and target for randomly spawned bubbles.

func ballRand() -> CGPoint {
    let randomChance = arc4random() % 4
    let randomHeight = CGFloat(arc4random() % 768)
    let randomWidth = CGFloat(arc4random() % 1024)
    var x = CGFloat(0)
    var y = CGFloat(0)
    switch randomChance {
    case 0:
        x = -20
        y = randomHeight
    case 1:
        x = 1044
        y = randomHeight
    case 2:
        x = randomWidth
        y = 788
    case 3:
        x = randomWidth
        y = -20
    default:break
    }
    return CGPoint(x: x, y: y)
}

//This function sets up a physics body for our projectiles

func projectilePhysicsBody(_ contactBitMask: UInt32) -> SKPhysicsBody {
    let MyPhysicsBody = SKPhysicsBody(circleOfRadius: 32)
    MyPhysicsBody.contactTestBitMask = contactBitMask
    MyPhysicsBody.isDynamic = true
    MyPhysicsBody.usesPreciseCollisionDetection = true
    MyPhysicsBody.allowsRotation = false
    return MyPhysicsBody
}

//This function generates a particle effect

var particleBank = [String: SKNode]()

func findPoof(_ name: String) -> SKNode {
    if let node = particleBank[name] {
        return node.copy() as! SKNode
    } else {
        guard let node = SKNode(fileNamed: name) else {
            fatalError("FatalError: Unable to load resource named \(name)")
        }
        particleBank[name] = node
        return node.copy() as! SKNode
    }
}

func addPoof(_ name: String, position: CGPoint, duration: TimeInterval) {
    let poof: SKNode
    if name == "SparkPoof" {
        let tempChild = findPoof(name).childNode(withName: name)!
        tempChild.removeFromParent()
        poof = tempChild
        Finder.addChild(poof)
        poof.zPosition = 0.5
    } else {
        poof = findPoof(name)
        poof.position = position
        currentScene.addChild(poof)
        poof.zPosition = 9.5
    }
    poof.run(.sequence([.wait(forDuration: duration), .fadeOut(withDuration: duration), .removeFromParent()]))
}

//Firing or spawning functions for different kinds of projectiles

func fireBlue(_ point: CGPoint) {
    if attackCooldown == 0 {
        let projectile = GameResources.blueBubble.copy() as! SKSpriteNode
        projectile.zPosition = 2
        projectile.position = Finder.position
        projectile.physicsBody = projectilePhysicsBody(contactBitMask_Blue)
        Projectiles.addChild(projectile)
        
        Finder.run(.sequence([.scale(to: 1.2, duration: 0.15), .scale(to: 1.0, duration: 0.15)]))
        
        let shootAction = SKAction.sequence([.move(to: shootAtDirection(point, projectile.position), duration: 1.6), .removeFromParent()])
        
        if muteSound {
            projectile.run(shootAction)
        } else {
            projectile.run(.sequence([shootSoundAction, shootAction]))
        }
        
        attackCooldown = 0.4
    }
}

func fireCyan(_ point: CGPoint) {
    if alternateAttackCooldown == 0 {
        let projectile = GameResources.cyanBubble.copy() as! SKSpriteNode
        projectile.zPosition = 1
        projectile.position = Finder.position
        projectile.physicsBody = projectilePhysicsBody(contactBitMask_Cyan)
        Projectiles.addChild(projectile)
        
        Finder.run(.sequence([.scale(to: 1.1, duration: 0.05), .scale(to: 1.0, duration: 0.05)]))
        
        let shootAction = SKAction.sequence([.move(to: shootAtDirection(point, projectile.position), duration: 0.8), .removeFromParent()])
        
        if muteSound {
            projectile.run(shootAction)
        } else {
            projectile.run(.sequence([shootSoundAction, shootAction]))
        }
        
        alternateAttackCooldown = 0.2
    }
}

func fireRed(_ point: CGPoint) {
    let projectile = GameResources.redBubble.copy() as! SKSpriteNode
    projectile.zPosition = 3
    projectile.position = point
    projectile.physicsBody = projectilePhysicsBody(contactBitMask_Red)
    Hostiles.addChild(projectile)
    
    let shootAction = SKAction.sequence([.move(to: shootAtDirection(Finder.position, projectile.position), duration: 4.8 - addedDifficulty * 3.2), .removeFromParent()])
    
    if muteSound {
        projectile.run(shootAction)
    } else {
        projectile.run(.sequence([shootSoundAction, shootAction]))
    }
}

func firePurple(_ point: CGPoint) {
    let projectile = GameResources.purpleBubble.copy() as! SKSpriteNode
    projectile.zPosition = 1
    projectile.position = point
    projectile.physicsBody = projectilePhysicsBody(contactBitMask_Purple)
    Hostiles.addChild(projectile)
    
    let shootAction = SKAction.sequence([.move(to: shootAtDirection(Finder.position, projectile.position), duration: 3.2 - addedDifficulty * 2), .removeFromParent()])
    
    if muteSound {
        projectile.run(shootAction)
    } else {
        projectile.run(.sequence([shootSoundAction, shootAction]))
    }
}

func fireAndroid(fromPoint point: CGPoint, toPoint target: CGPoint) {
    let projectile = GameResources.android.copy() as! SKSpriteNode
    projectile.zPosition = 4
    projectile.position = point
    projectile.physicsBody = projectilePhysicsBody(contactBitMask_Android)
    Hostiles.addChild(projectile)
    
    projectile.run(.sequence([.move(to: target, duration: 2.4 - addedDifficulty * 1.4), .removeFromParent()]))
    projectile.run(SKAction(named: "Breathing")!)
}

func spawnGreen() {
    let randomGreen = arc4random() % 10
    if randomGreen == 0 { //Normal Code
    //if randomGreen < 5 { //Debug Code
        let projectile = GameResources.greenBubble.copy() as! SKSpriteNode
        projectile.zPosition = 5
        projectile.position = ballRand()
        projectile.physicsBody = projectilePhysicsBody(contactBitMask_Green)
        Projectiles.addChild(projectile)
    
        projectile.run(.sequence([.move(to: ballRand(), duration: 2.4), .removeFromParent()]))
    }
}

//Two functions for handling SKPhysicsBody contacts

func contactSort(_ contact: SKPhysicsContact) {
    if contact.bodyA.contactTestBitMask < contact.bodyB.contactTestBitMask {
        contactTest(contact.bodyA, contact.bodyB)
    } else {
        contactTest(contact.bodyB, contact.bodyA)
    }
}

func contactTest(_ bodyA: SKPhysicsBody, _ bodyB: SKPhysicsBody) {
    if let contactNodeA = bodyA.node {
        guard contactNodeA.parent != nil else { return }
        if let contactNodeB = bodyB.node {
            guard contactNodeB.parent != nil else { return }
            switch bodyA.contactTestBitMask {
            case contactBitMask_Finder:
                switch bodyB.contactTestBitMask {
                case contactBitMask_Android: //Finder vs Android (Health -4)
                    addPoof("AndroidPoof", position: contactNodeB.position, duration: 0.2)
                    addPoof("Bleed", position: contactNodeB.position, duration: 0.4)
                    contactNodeB.removeFromParent()
                    health -= 4
                    if !muteSound {
                        currentScene.run(.playSoundFileNamed("red.mp3", waitForCompletion: false))
                    }
                case contactBitMask_Red: //Finder vs Red (Health -2)
                    addPoof("RedPoof", position: contactNodeB.position, duration: 0.2)
                    addPoof("Bleed", position: contactNodeB.position, duration: 0.2)
                    contactNodeB.removeFromParent()
                    health -= 2
                    if !muteSound {
                        currentScene.run(.playSoundFileNamed("red.mp3", waitForCompletion: false))
                    }
                case contactBitMask_Purple: //Finder vs Purple (Health -1)
                    addPoof("PurplePoof", position: contactNodeB.position, duration: 0.2)
                    addPoof("Bleed", position: contactNodeB.position, duration: 0.4)
                    contactNodeB.removeFromParent()
                    health -= 1
                    if !muteSound {
                        currentScene.run(.playSoundFileNamed("blast.mp3", waitForCompletion: false))
                    }
                case contactBitMask_Green: //Finder vs Green (Smite Power-up)
                    contactNodeB.removeFromParent()
                    Hostiles.removeAllChildren()
                    (Effects.children[0] as! SKEmitterNode).yAcceleration = -10000
                    var poofPoint: CGPoint
                    if let boss = currentScene.childNode(withName: "Boss") {
                        poofPoint = boss.position
                    } else if let terminal = currentScene.childNode(withName: "Terminal") {
                        poofPoint = terminal.position
                    } else {
                        poofPoint = currentScene.childNode(withName: "//BaseEnemy")!.position
                    }
                    addPoof("Bleed", position: poofPoint, duration: 0.5)
                    Finder.run(.repeat(.sequence([
                        .scale(by: 1.05, duration: 0.1),
                        .wait(forDuration: 0.1),
                        .run({
                            Hostiles.removeAllChildren()
                            score += 1
                            enemyhealth -= 1
                        })
                        ]), count: 5), completion: {
                            contactNodeA.run(.scale(to: 1.0, duration: 0.4))
                            (Effects.children[0] as! SKEmitterNode).yAcceleration = 0
                            let damage = Int(Double(100 - enemyhealth) * 0.3)
                            enemyhealth -= damage
                            score += damage
                            if let boss = currentScene.childNode(withName: "Boss") {
                                poofPoint = boss.position
                            } else if let terminal = currentScene.childNode(withName: "Terminal") {
                                poofPoint = terminal.position
                            } else {
                                poofPoint = currentScene.childNode(withName: "//BaseEnemy")!.position
                            }
                            for _ in 1...4 {
                                addPoof("Bleed", position: poofPoint, duration: 0.2)
                                addPoof("Bleed", position: poofPoint, duration: 0.2)
                                addPoof("Bleed", position: poofPoint, duration: 0.2)
                            }
                            addPoof("SmitePoof", position: poofPoint, duration: 0.2)
                        }
                    )
                    health += 2
                    if !muteSound {
                        Finder.run(.sequence([.playSoundFileNamed("respawn.mp3", waitForCompletion: false),
                                              .wait(forDuration: 0.5),
                                              .playSoundFileNamed("power.mp3", waitForCompletion: false)]))
                    }
                default: break
                }
            case contactBitMask_Android:
                switch bodyB.contactTestBitMask {
                case contactBitMask_Blue: //Android vs Blue (Destroys Both)
                    addPoof("Bleed", position: contactNodeA.position, duration: 0.2)
                    addPoof("BluePoof", position: contactNodeB.position, duration: 0.2)
                    contactNodeA.removeFromParent()
                    contactNodeB.removeFromParent()
                    if currentScene.isKind(of: Game1.self) {
                        score += 1
                        enemyhealth -= 1
                    }
                    if !muteSound {
                        currentScene.run(.playSoundFileNamed("blue.mp3", waitForCompletion: false))
                    }
                case contactBitMask_Enemy: //Android vs Enemy (Enemyhealth +4)
                    contactNodeA.removeFromParent()
                    enemyhealth += 4
                    if score > (level - 1) * 100 {
                        score -= 4
                    }
                    if score < (level - 1) * 100 {
                        score = (level - 1) * 100
                    }
                default: break
                }
            case contactBitMask_Enemy:
                switch bodyB.contactTestBitMask {
                case contactBitMask_Blue: //Enemy vs Blue (Enemyhealth -1)
                    addPoof("BluePoof", position: contactNodeB.position, duration: 0.2)
                    addPoof("BluePoof", position: contactNodeB.position, duration: 0.2)
                    addPoof("Bleed", position: contactNodeB.position, duration: 0.1)
                    contactNodeB.removeFromParent()
                    score += 1
                    enemyhealth -= 1
                    if !muteSound {
                        currentScene.run(.playSoundFileNamed("blue.mp3", waitForCompletion: false))
                    }
                case contactBitMask_Cyan: //Enemy vs Cyan (Enemyhealth -1)
                    addPoof("CyanPoof", position: contactNodeB.position, duration: 0.2)
                    addPoof("CyanPoof", position: contactNodeB.position, duration: 0.2)
                    addPoof("Bleed", position: contactNodeB.position, duration: 0.1)
                    contactNodeB.removeFromParent()
                    score += 1
                    enemyhealth -= 1
                    if !muteSound {
                        currentScene.run(.playSoundFileNamed("cyan.mp3", waitForCompletion: false))
                    }
                default: break
                }
            case contactBitMask_Blue:
                switch bodyB.contactTestBitMask {
                case contactBitMask_Purple: //Blue vs Purple (Destroys Purple)
                    addPoof("BluePoof", position: contactNodeA.position, duration: 0.1)
                    addPoof("PurplePoof", position: contactNodeB.position, duration: 0.2)
                    contactNodeB.removeFromParent()
                    if !muteSound {
                        currentScene.run(.playSoundFileNamed("purple.mp3", waitForCompletion: false))
                    }
                case contactBitMask_Green: //Blue vs Green (Normal Power-up)
                    addPoof("GreenPoof", position: contactNodeB.position, duration: 0.5)
                    contactNodeA.removeFromParent()
                    contactNodeB.removeFromParent()
                    Hostiles.removeAllChildren()
                    (Effects.children[0] as! SKEmitterNode).yAcceleration = -10000
                    Finder.run(.repeat(.sequence([.rotate(byAngle: -3.1415926, duration: 0.1), .run({
                        Hostiles.removeAllChildren()
                        score += 1
                        enemyhealth -= 1
                    })]), count: 10), completion: {(Effects.children[0] as! SKEmitterNode).yAcceleration = 0})
                    health += 2
                    if !muteSound {
                        currentScene.run(.playSoundFileNamed("power.mp3", waitForCompletion: false))
                    }
                default: break
                }
            case contactBitMask_Cyan:
                switch bodyB.contactTestBitMask {
                case contactBitMask_Red: //Cyan vs Red (Destroys Cyan)
                    contactNodeA.removeFromParent()
                    if !muteSound {
                        currentScene.run(.playSoundFileNamed("purple.mp3", waitForCompletion: false))
                    }
                case contactBitMask_Purple: //Cyan vs Purple (Destroys Both)
                    addPoof("CyanPoof", position: contactNodeA.position, duration: 0.2)
                    addPoof("PurplePoof", position: contactNodeB.position, duration: 0.2)
                    contactNodeA.removeFromParent()
                    contactNodeB.removeFromParent()
                    if !muteSound {
                        currentScene.run(.playSoundFileNamed("purple.mp3", waitForCompletion: false))
                    }
                case contactBitMask_Green: //Cyan vs Green (Alternate Power-up)
                    addPoof("SparkPoof", position: Finder.position, duration: 0.4)
                    contactNodeB.removeFromParent()
                    Hostiles.removeAllChildren()
                    (Effects.children[0] as! SKEmitterNode).yAcceleration = -10000
                    let poofPoint: CGPoint
                    if let boss = currentScene.childNode(withName: "Boss") {
                        poofPoint = boss.position
                    } else {
                        poofPoint = currentScene.childNode(withName: "Terminal")!.position
                    }
                    addPoof("Bleed", position: poofPoint, duration: 0.4)
                    addPoof("Bleed", position: poofPoint, duration: 0.4)
                    Finder.run(.repeat(.sequence([.run({
                        if let x = currentScene.childNode(withName: "Terminal") {
                            x.removeAllActions()
                        }
                        Hostiles.removeAllChildren()
                        score += 2
                        enemyhealth -= 2
                    }),
                                                  //.waitForDuration(0.1)
                        .rotate(byAngle: -3.1415926, duration: 0.1)
                        ]), count: 6), completion: {(Effects.children[0] as! SKEmitterNode).yAcceleration = 0})
                    health += 1
                    if !muteSound {
                        currentScene.run(.playSoundFileNamed("spark.mp3", waitForCompletion: false))
                    }
                default: break
                }
            default: break
            }
        }
    }
}

//Enemy respawn function for Challenge Mode

func emptyHealthAction(_ endBlock: @escaping ()->()) {
    
    let HBTEnemy = currentScene.childNode(withName: "//HBTEnemy")!
    let HBEnemy = currentScene.childNode(withName: "//HBEnemy")!
    
    HBTEnemy.run(.scaleX(to: 0, duration: 0.0))
    HBTEnemy.run(.moveTo(x: -60, duration: 0.0))
    HBEnemy.run(.scaleX(to: 0, duration: 0.5))
    HBEnemy.run(.moveTo(x: -60, duration: 0.5))
    
    currentScene.run(.repeat(.sequence([
        .run({
            Hostiles.removeAllChildren()
            Projectiles.removeAllChildren()
            Finder.removeAllActions()
            (Effects.children[0] as! SKEmitterNode).yAcceleration = 0
            enemyhealth = -1000
            Finder.zRotation = 0
            Finder.xScale = 1
            Finder.yScale = 1
        }), .wait(forDuration: 0.01)]), count: 75), completion: endBlock)
    
    let boom = GameResources.boom.copy() as! SKSpriteNode
    boom.xScale = 0.1
    boom.yScale = 0.1
    boom.zPosition = 9
    
    if !muteSound {
        currentScene.run(.playSoundFileNamed("respawn.mp3", waitForCompletion: false))
    }
    
    switch maxhealth {
    case 4:
        boom.position = currentScene.childNode(withName: "Terminal")!.position
    case 8:
        boom.position = currentScene.childNode(withName: "Boss")!.position
    default:
        boom.position = Finder.position
    }
    
    boom.run(.scale(to: 6, duration: 1.0))
    boom.run(.sequence([.fadeOut(withDuration: 1.0), .removeFromParent()]))
    
    currentScene.addChild(boom)
}

//Refresh actions when scene becomes active / every second  / every tenth second / every frame

func refreshPerSecond() -> Bool {
    if timeElapsed >= lastSpawnTime + 1 && !menuOn {
        spawnGreen()
        lastSpawnTime = timeElapsed
        return true
    }
    return false
}

func refreshPerTenthSecond(_ currentTime: TimeInterval) -> Bool {
    if Int(currentTime * 10) >= Int(oldTime + 1) && !menuOn {
        timeElapsed += 0.1
        if attackCooldown > 0 {
            attackCooldown -= 0.1
        } else {
            attackCooldown = 0
        }
        if alternateAttackCooldown > 0 {
            alternateAttackCooldown -= 0.1
        } else {
            alternateAttackCooldown = 0
        }
        if enemyAttackCooldown > 0 {
            enemyAttackCooldown -= 0.1
        } else {
            enemyAttackCooldown = 0
        }
        return true
    }
    return false
}

func refreshPerFrame(_ currentTime: TimeInterval) {
    if menuOn {
        menu.isPaused = false
        for child in currentScene.children {
            if !(child === menu) {
                child.isPaused = true
            }
        }
    } else {
        //Visualizing damage and regeneration in health bars
        
        let HBTFinder = currentScene.childNode(withName: "//HBTFinder")!
        let HBFinder = currentScene.childNode(withName: "//HBFinder")!
        let HBTEnemy = currentScene.childNode(withName: "//HBTEnemy")!
        let HBEnemy = currentScene.childNode(withName: "//HBEnemy")!
        
        if health > maxhealth {health = maxhealth}
        if enemyhealth > 100 {enemyhealth = 100}
        
        let newHealthScale = CGFloat(health) / CGFloat(maxhealth)
        let newHealthX = -(60 - (60 * (CGFloat(health) / CGFloat(maxhealth))))
        let newEnemyHealthScale = CGFloat(enemyhealth) / 100
        let newEnemyHealthX = -(60 - (60 * (CGFloat(enemyhealth) / 100)))
        
        if health >= 0 {
            if health > oldHealth {
                HBTFinder.run(.scaleX(to: newHealthScale, duration: 0.25), completion: {})
                HBTFinder.run(.moveTo(x: newHealthX, duration: 0.25), completion: {oldHealth = health})
                HBFinder.run(.scaleX(to: newHealthScale, duration: 0.25))
                HBFinder.run(.moveTo(x: newHealthX, duration: 0.25))
            } else {
                HBTFinder.run(.scaleX(to: newHealthScale, duration: 0.0))
                HBTFinder.run(.moveTo(x: newHealthX, duration: 0.0))
                HBFinder.run(.scaleX(to: newHealthScale, duration: 0.5))
                HBFinder.run(.moveTo(x: newHealthX, duration: 0.5))
            }
        } else {
            HBTFinder.run(.scaleX(to: 0, duration: 0.0))
            HBTFinder.run(.moveTo(x: -60, duration: 0.0))
            currentScene.childNode(withName: "//HBFinder")!.run(.scaleX(to: 0, duration: 0.5))
            currentScene.childNode(withName: "//HBFinder")!.run(.moveTo(x: -60, duration: 0.5))
        }
        
        if enemyhealth > 0 && enemyhealth < 100 {
            if enemyhealth > oldEnemyHealth {
                HBTEnemy.run(.scaleX(to: newEnemyHealthScale, duration: 0.25), completion: {oldEnemyHealth = enemyhealth})
                HBTEnemy.run(.moveTo(x: newEnemyHealthX, duration: 0.25), completion: {oldEnemyHealth = enemyhealth})
                HBEnemy.run(.scaleX(to: newEnemyHealthScale, duration: 0.25))
                HBEnemy.run(.moveTo(x: newEnemyHealthX, duration: 0.25))
            } else {
                HBTEnemy.run(.scaleX(to: newEnemyHealthScale, duration: 0.0))
                HBTEnemy.run(.moveTo(x: newEnemyHealthX, duration: 0.0))
                HBEnemy.run(.scaleX(to: newEnemyHealthScale, duration: 0.5))
                HBEnemy.run(.moveTo(x: newEnemyHealthX, duration: 0.5))
            }
        } else if enemyhealth <= 0 {
            HBTEnemy.run(.scaleX(to: 0, duration: 0.0))
            HBTEnemy.run(.moveTo(x: -60, duration: 0.0))
            HBEnemy.run(.scaleX(to: 0, duration: 0.5))
            HBEnemy.run(.moveTo(x: -60, duration: 0.5))
        }
        
        if health <= 0 && health > -10 {
            health = -20
            currentScene.run(.repeat(.sequence([.wait(forDuration: 0.01), .run({
                Finder.removeAllActions()
                Projectiles.removeAllChildren()
            })]), count: 50))
            if adventureModeOn {
                if muteSound {
                    currentScene.run(.wait(forDuration: 0.5), completion: {currentScene.view!.presentScene(GameAdventureOver(fileNamed: "GameAdventureOver")!, transition: .fade(withDuration: 1.0))})
                } else {
                    currentScene.run(.sequence([.playSoundFileNamed("lose.mp3", waitForCompletion: false), .wait(forDuration: 0.5)]), completion: {currentScene.view!.presentScene(GameAdventureOver(fileNamed: "GameAdventureOver")!, transition: .fade(withDuration: 1.0))})
                }
            } else {
                if muteSound {
                    currentScene.run(.wait(forDuration: 0.5), completion: {currentScene.view!.presentScene(GameOverScene(fileNamed: "GameOver")!, transition: .fade(withDuration: 1.0))})
                } else {
                    currentScene.run(.sequence([.playSoundFileNamed("lose.mp3", waitForCompletion: false), .wait(forDuration: 0.5)]), completion: {currentScene.view!.presentScene(GameOverScene(fileNamed: "GameOver")!, transition: .fade(withDuration: 1.0))})
                }
            }
        }
        
        //Tests if enemy is dead: If in Adventure mode, complete the level; if in Challenge mode, revive the enemy and add difficulty.
        
        if enemyhealth <= 0 && enemyhealth > -100 {
            if adventureModeOn {
                emptyHealthAction({
                    AdventureLevel += 1
                    AdventureStage = 1
                    if muteSound {
                        currentScene.run(.wait(forDuration: 0.5), completion: {currentScene.view!.presentScene(GameAdventureController(fileNamed: "Adventure\(AdventureLevel)-\(AdventureStage)")!, transition: .fade(withDuration: 1.0))})
                    } else {
                        currentScene.run(.sequence([.playSoundFileNamed("win.mp3", waitForCompletion: false), .wait(forDuration: 0.5)]), completion: {currentScene.view!.presentScene(GameAdventureController(fileNamed: "Adventure\(AdventureLevel)-\(AdventureStage)")!, transition: .fade(withDuration: 1.0))})
                    }
                })
            } else {
                level += 1
                if level > 6 {level = 6}
                (currentScene.childNode(withName: "//ValueLevel") as! SKLabelNode).text = "\(level)"
                addedDifficulty = Double(level - 1) * 0.24
                
                emptyHealthAction({
                    HBTEnemy.run(.scaleX(to: 1, duration: 1.0))
                    HBTEnemy.run(.moveTo(x: 0, duration: 1.0))
                    HBEnemy.run(.scaleX(to: 1, duration: 1.0))
                    HBEnemy.run(.moveTo(x: 0, duration: 1.0))
                    
                    currentScene.run(.repeat(.sequence([.wait(forDuration: 0.01),
                        .run({
                            Hostiles.removeAllChildren()
                            Projectiles.removeAllChildren()
                            Finder.removeAllActions()
                            (Effects.children[0] as! SKEmitterNode).yAcceleration = 0
                            enemyhealth = 100
                            Finder.zRotation = 0
                            Finder.xScale = 1
                            Finder.yScale = 1
                            score = (level - 1) * 100
                        })]), count: 125))
                })
            }
        }
        
        //Moves Finder (Turns Movement Queues into Actions)
        if leftQueue {
            velocityX -= 10
        }
        
        if rightQueue {
            velocityX += 10
        }
        
        if upQueue {
            velocityY += 10
        }
        
        if downQueue {
            velocityY -= 10
        }
        
        if Finder.position.x < 50 {
            Finder.position.x = 51
            velocityX = 0
        } else if Finder.position.x > 974 {
            Finder.position.x = 974
            velocityX = 0
        }
        
        if Finder.position.y < 50 {
            Finder.position.y = 51
            velocityY = 0
        } else if Finder.position.y > 718 {
            Finder.position.y = 718
            velocityY = 0
        }
        
        if velocityX > 0 {
            Finder.run(.moveBy(x: 10, y: 0, duration: 0.1))
            velocityX -= 10
        } else if velocityX < 0 {
            Finder.run(.moveBy(x: -10, y: 0, duration: 0.1))
            velocityX += 10
        }
        
        if velocityY > 0 {
            Finder.run(.moveBy(x: 0, y: 10, duration: 0.1))
            velocityY -= 10
        } else if velocityY < 0 {
            Finder.run(.moveBy(x: 0, y: -10, duration: 0.1))
            velocityY += 10
        }
        
        currentScene.childNode(withName: "//BaseFinder")!.position.x = Finder.position.x
        if Finder.position.y > 680 {
            currentScene.childNode(withName: "//BaseFinder")!.position.y = Finder.position.y - 75
        } else {
            currentScene.childNode(withName: "//BaseFinder")!.position.y = Finder.position.y + 75
        }
        
        if maxhealth == 4 {
            let Terminal = currentScene.childNode(withName: "//Terminal")!
            currentScene.childNode(withName: "//BaseEnemy")!.position.x = Terminal.position.x
            if Terminal.position.y > 680 {
                currentScene.childNode(withName: "//BaseEnemy")!.position.y = Terminal.position.y - 75
            } else {
                currentScene.childNode(withName: "//BaseEnemy")!.position.y = Terminal.position.y + 75
            }
        }
        
        //Triggering fireBlue() and fireCyan()
        
        currentScene.childNode(withName: "tap")!.position = CGPoint(x: -100, y: -100)
        
        if let x = attackPoint {
            if maxhealth < 4 {
                fireBlue(x)
            } else {
                if leftQueue || rightQueue || upQueue || downQueue  {
                    fireCyan(x)
                } else {
                    fireBlue(x)
                }
            }
            
            currentScene.childNode(withName: "tap")!.position = x
        }
        
        //Some necessary BGM tests
        
        if muteMusic {
            bgm.volume = 0
        } else {
            bgm.volume = 1
        }
        
        if !bgm.isPlaying {
            bgm.play()
        }
        
        //Cheat tester
        
        let scoreDelta = score - Int(oldFrameScore)!
        if scoreDelta > 50 {
            fatalError("Fuck you cheater! (Δ: \(scoreDelta))")
        }
 
        oldFrameScore = "\(score)"
        
        //Final changes in the frame update
        
        if record < score {
            record = score
            standardDefaults.set(score, forKey: "record\(Int(log2(Double(maxhealth * 2))))")
            standardDefaults.synchronize()
        }
        
        (currentScene.childNode(withName: "Record") as! SKLabelNode).text = NSLocalizedString("TextRecord", comment: "Record: ") + "\(record)"
        
        oldTime = Int(currentTime * 10)
        if oldHealth > health {
            oldHealth = health
        }
        if oldEnemyHealth > enemyhealth {
            oldEnemyHealth = enemyhealth
        }
        (currentScene.childNode(withName: "Score") as! SKLabelNode).text = "\(score)"
    }
}
