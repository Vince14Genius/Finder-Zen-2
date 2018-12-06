//
//  GameScene.swift
//  Finder Zen 2
//
//  Created by Vince14Genius on 9/8/15.
//  Copyright © 2015 Vince14Genius. All rights reserved.
//

import SpriteKit
import AVFoundation

var bgm = AVAudioPlayer()
var resetRecord = 0
var muteMusic = false
var muteSound = false

func localizeLabelsInScene(_ scene: SKScene) {
    for node in scene.children {
        if let x = node as? SKLabelNode {
            if x.name! != "Text" {
                x.text = NSLocalizedString(x.name!, comment: "")
            }
        } else {
            for nodeChild in node.children {
                if let x = nodeChild as? SKLabelNode {
                    if x.name! != "Text" {
                        x.text = NSLocalizedString(x.name!, comment: "")
                    }
                }
            }
        }
    }
}

class GameScene: SKScene {
    
    enum buttons {
        case none
        case buttonAdventure
        case buttonChallenge
        case muteMusic
        case muteSound
    }
    
    var clickedButton = buttons.none
    
    override func didMove(to view: SKView) {
        localizeLabelsInScene(self)
        
        muteMusic = standardDefaults.bool(forKey: "muteMusic")
        muteSound = standardDefaults.bool(forKey: "muteSound")
        
        childNode(withName: "//MuteMusicX")!.isHidden = !muteMusic
        childNode(withName: "//MuteSoundX")!.isHidden = !muteSound
        
        do {
            try bgm = AVAudioPlayer(contentsOf: Bundle.main.url(forResource: "title", withExtension: "mp3")!)
        } catch {
            fatalError("Failed to load AVAudioPlayer")
        }
        bgm.volume = 1
    }
    
    override func mouseDown(with theEvent: NSEvent) {
        let point = theEvent.location(in: self)
        let clickedNode = atPoint(point)
        
        clickedButton = .none
        
        if clickedNode === childNode(withName: "ButtonAdventure") {
            clickedButton = .buttonAdventure
            clickedNode.alpha = 0.5
        } else if clickedNode === childNode(withName: "ButtonChallenge") {
            clickedButton = .buttonChallenge
            clickedNode.alpha = 0.5
        } else if clickedNode === childNode(withName: "MuteMusic") || clickedNode.parent === childNode(withName: "MuteMusic") {
            clickedButton = .muteMusic
            childNode(withName: "MuteMusic")!.alpha = 0.5
        } else if clickedNode === childNode(withName: "MuteSound") || clickedNode.parent === childNode(withName: "MuteSound") {
            clickedButton = .muteSound
            childNode(withName: "MuteSound")!.alpha = 0.5
        }
    }
    
    override func mouseUp(with theEvent: NSEvent) {
        let point = theEvent.location(in: self)
        let clickedNode = atPoint(point)
        
        if clickedNode === childNode(withName: "ButtonAdventure") && clickedButton == .buttonAdventure {
            adventureModeOn = true
            AdventureLevel = 1
            AdventureStage = 1
            if !muteSound {
                run(.playSoundFileNamed("respawn.mp3", waitForCompletion: false))
            }
            view!.presentScene(GameAdventureController(fileNamed: "Adventure1-1")!, transition: .fade(withDuration: 2.0))
        } else if clickedNode === childNode(withName: "ButtonChallenge")! && clickedButton == .buttonChallenge {
            view!.presentScene(GameChallengeScene(fileNamed: "GameChallengeScene")!, transition: .push(with: .left, duration: 0.5))
        } else if clickedNode === childNode(withName: "MuteMusic") || clickedNode.parent === childNode(withName: "MuteMusic") {
            if clickedButton == .muteMusic {
                muteMusic = !muteMusic
                standardDefaults.set(muteMusic, forKey: "muteMusic")
                childNode(withName: "//MuteMusicX")!.isHidden = !muteMusic
            }
        } else if clickedNode === childNode(withName: "MuteSound") || clickedNode.parent === childNode(withName: "MuteSound") {
            if clickedButton == .muteSound {
                muteSound = !muteSound
                standardDefaults.set(muteSound, forKey: "muteSound")
                childNode(withName: "//MuteSoundX")!.isHidden = !muteSound
            }
        }
        
        clickedButton = .none
        childNode(withName: "ButtonAdventure")!.alpha = 1
        childNode(withName: "ButtonChallenge")!.alpha = 1
        childNode(withName: "MuteMusic")!.alpha = 1
        childNode(withName: "MuteSound")!.alpha = 1
    }
    
    override func update(_ currentTime: TimeInterval) {
        if muteMusic {
            bgm.volume = 0
        } else {
            bgm.volume = 1
        }
        
        if !bgm.isPlaying {
            bgm.play()
        }
    }
}

class GameChallengeScene: SKScene {
    
    enum buttons {
        case none
        case home
        case button1
        case button2
        case button3
        case button4
        case reset1
        case reset2
        case reset3
        case reset4
    }
    
    var clickedButton = buttons.none
    
    override func didMove(to view: SKView) {
        localizeLabelsInScene(self)
        
        adventureModeOn = false
        for i in 1...4 {
            (childNode(withName: "//Record\(i)") as! SKLabelNode).text = NSLocalizedString("TextRecord", comment: "Record: ") + "\(standardDefaults.integer(forKey: "record\(i)"))"
        }
    }
    
    override func mouseDown(with theEvent: NSEvent) {
        let clickedNode = atPoint(theEvent.location(in: self))
        
        clickedButton = .none
        
        if clickedNode === childNode(withName: "ButtonHome") {
            clickedButton = .home
            childNode(withName: "ButtonHome")!.alpha = 0.5
        } else if clickedNode === childNode(withName: "Button1") {
            clickedButton = .button1
            childNode(withName: "Button1")!.alpha = 0.5
        } else if clickedNode === childNode(withName: "Button2") {
            clickedButton = .button2
            childNode(withName: "Button2")!.alpha = 0.5
        } else if clickedNode === childNode(withName: "Button3") {
            clickedButton = .button3
            childNode(withName: "Button3")!.alpha = 0.5
        } else if clickedNode === childNode(withName: "Button4") {
            clickedButton = .button4
            childNode(withName: "Button4")!.alpha = 0.5
        } else if clickedNode === childNode(withName: "Reset1") {
            clickedButton = .reset1
            childNode(withName: "Reset1")!.alpha = 0.5
        } else if clickedNode === childNode(withName: "Reset2") {
            clickedButton = .reset2
            childNode(withName: "Reset2")!.alpha = 0.5
        } else if clickedNode === childNode(withName: "Reset3") {
            clickedButton = .reset3
            childNode(withName: "Reset3")!.alpha = 0.5
        } else if clickedNode === childNode(withName: "Reset4") {
            clickedButton = .reset4
            childNode(withName: "Reset4")!.alpha = 0.5
        }
    }
    
    override func mouseUp(with theEvent: NSEvent) {
        let clickedNode = atPoint(theEvent.location(in: self))
        
        if clickedNode === childNode(withName: "ButtonHome") && clickedButton == .home {
            view!.presentScene(GameScene(fileNamed: "GameScene")!, transition: .push(with: .right, duration: 0.5))
        } else if clickedNode === childNode(withName: "Button1") {
            if clickedButton == .button1 {
                view!.presentScene(Game1(fileNamed: "Game1")!, transition: .fade(withDuration: 0.5))
            }
        } else if clickedNode === childNode(withName: "Button2") {
            if clickedButton == .button2 {
                view!.presentScene(Game2(fileNamed: "Game2")!, transition: .fade(withDuration: 0.5))
            }
        } else if clickedNode === childNode(withName: "Button3") {
            if clickedButton == .button3 {
                view!.presentScene(Game3(fileNamed: "Game3")!, transition: .fade(withDuration: 0.5))
            }
        } else if clickedNode === childNode(withName: "Button4") {
            if clickedButton == .button4 {
                view!.presentScene(Game4(fileNamed: "Game4")!, transition: .fade(withDuration: 0.5))
            }
        } else if clickedNode === childNode(withName: "Reset1") {
            if clickedButton == .reset1 {
                resetRecord = 1
                view!.presentScene(GameConfirmScene(fileNamed: "GameConfirmScene")!, transition: .fade(withDuration: 0.5))
            }
        } else if clickedNode === childNode(withName: "Reset2") {
            if clickedButton == .reset2 {
                resetRecord = 2
                view!.presentScene(GameConfirmScene(fileNamed: "GameConfirmScene")!, transition: .fade(withDuration: 0.5))
            }
        } else if clickedNode === childNode(withName: "Reset3") {
            if clickedButton == .reset3 {
                resetRecord = 3
                view!.presentScene(GameConfirmScene(fileNamed: "GameConfirmScene")!, transition: .fade(withDuration: 0.5))
            }
        } else if clickedNode === childNode(withName: "Reset4") {
            if clickedButton == .reset4 {
                resetRecord = 4
                view!.presentScene(GameConfirmScene(fileNamed: "GameConfirmScene")!, transition: .fade(withDuration: 0.5))
            }
        }
        
        clickedButton = .none
        childNode(withName: "ButtonHome")!.alpha = 1
        childNode(withName: "Button1")!.alpha = 1
        childNode(withName: "Button2")!.alpha = 1
        childNode(withName: "Button3")!.alpha = 1
        childNode(withName: "Button4")!.alpha = 1
        childNode(withName: "Reset1")!.alpha = 1
        childNode(withName: "Reset2")!.alpha = 1
        childNode(withName: "Reset3")!.alpha = 1
        childNode(withName: "Reset4")!.alpha = 1
    }
    
    override func update(_ currentTime: TimeInterval) {
        if muteMusic {
            bgm.volume = 0
        } else {
            bgm.volume = 1
        }
        
        if !bgm.isPlaying {
            bgm.play()
        }
    }
}

class GameOverScene: SKScene {
    
    override func didMove(to view: SKView) {
        localizeLabelsInScene(self)
        
        let gameId = Int(log2(Double(maxhealth * 2)))
        (childNode(withName: "Background") as! SKSpriteNode).texture = SKTexture(imageNamed: "Background\(gameId)")
        let recordWithId = standardDefaults.integer(forKey: "record\(gameId)")
        if recordWithId == score {
            (childNode(withName: "FinalScore") as! SKLabelNode).text = NSLocalizedString("TextNewRecord", comment: "NEW RECORD!!!")
        } else {
            (childNode(withName: "FinalScore") as! SKLabelNode).text = NSLocalizedString("TextFinalScore", comment: "Final Score:") + "\(score)"
        }
        (childNode(withName: "Record") as! SKLabelNode).text = NSLocalizedString("TextRecord", comment: "Record: ") + "\(recordWithId)"
        run(.run({bgm.volume = 0}))
    }
    
    override func mouseDown(with theEvent: NSEvent) {
        if let Scene = GameScene(fileNamed: "GameScene") {
            view!.presentScene(Scene, transition: .push(with: .right, duration: 0.5))
        }
    }
}

class GameConfirmScene: SKScene {
    
    enum buttons {
        case none
        case reset
        case cancel
    }
    
    var clickedButton = buttons.none
    
    override func didMove(to view: SKView) {
        localizeLabelsInScene(self)
        
        if let recordFor = (childNode(withName: "//recordFor") as? SKLabelNode) {
            switch resetRecord {
            case 1: recordFor.text = NSLocalizedString("TextAA", comment: "record for \"Awakening Adventure\"? ")
            case 2: recordFor.text = NSLocalizedString("TextGG", comment: "record for \"Guarded Getaway\"? ")
            case 3: recordFor.text = NSLocalizedString("TextTT", comment: "record for \"Terminal's Test\"? ")
            case 4: recordFor.text = NSLocalizedString("TextBB", comment: "record for \"Boss Battle\"? ")
            default: fatalError("Unexpected resetRecord argument. ")
            }
        }
    }
    
    override func mouseDown(with theEvent: NSEvent) {
        let point = theEvent.location(in: self)
        
        clickedButton = .none
        
        if point.y >= 256 && point.y <= 300 {
            switch point.x {
            case 256...511:
                clickedButton = .reset
                childNode(withName: "buttonReset")!.alpha = 0.5
            case 513...768:
                clickedButton = .cancel
                childNode(withName: "buttonCancel")!.alpha = 0.5
            default: break
            }
        }
    }
    
    override func mouseUp(with theEvent: NSEvent) {
        let point = theEvent.location(in: self)
        if point.y >= 256 && point.y <= 300 {
            switch point.x {
            case 256...511:
                if clickedButton == .reset {
                    standardDefaults.set(0, forKey: "record\(resetRecord)")
                    if !muteSound {
                        run(.playSoundFileNamed("respawn.mp3", waitForCompletion: false))
                    }
                    view!.presentScene(GameScene(fileNamed: "GameScene")!, transition: .fade(withDuration: 2.0))
                }
            case 513...768:
                if clickedButton == .cancel {
                    view!.presentScene(GameScene(fileNamed: "GameScene")!, transition: .fade(withDuration: 0.5))
                }
            default: break
            }
        }
        
        clickedButton = .none
        childNode(withName: "buttonReset")!.alpha = 1
        childNode(withName: "buttonCancel")!.alpha = 1
    }
    
    override func update(_ currentTime: TimeInterval) {
        if muteMusic {
            bgm.volume = 0
        } else {
            bgm.volume = 1
        }
        
        if !bgm.isPlaying {
            bgm.play()
        }
    }
}
