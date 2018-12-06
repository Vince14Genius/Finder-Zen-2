//
//  GameAdventureScene.swift
//  Finder Zen 2
//
//  Created by Vince14Genius on 2/25/16.
//  Copyright © 2016 Vince14Genius. All rights reserved.
//

import SpriteKit
import AVFoundation

var AdventureLevel = 1
var AdventureStage = 1

fileprivate func restartAction(inScene scene: SKScene) {
    guard let skView = scene.view else { return }
    skView.presentScene(GameAdventureController(fileNamed: "Adventure\(AdventureLevel)-\(AdventureStage)")!, transition: .fade(with: .white, duration: 2.0))
}

class GameAdventureController: SKScene {
    
    enum buttons {
        case none
        case mainMenu
        case watchAgain
    }
    
    var clickedButton = buttons.none
    
    func continueAction() {
        if AdventureLevel == 1 && AdventureStage == 18 {
            view!.presentScene(Game1(fileNamed: "Game1")!, transition: .fade(withDuration: 1.0))
        } else if AdventureLevel == 2 && AdventureStage == 3 {
            view!.presentScene(Game2(fileNamed: "Game2")!, transition: .fade(withDuration: 1.0))
        } else if AdventureLevel == 3 && AdventureStage == 6 {
            view!.presentScene(Game3(fileNamed: "Game3")!, transition: .fade(withDuration: 1.0))
        } else if AdventureLevel == 4 && AdventureStage == 8 {
            view!.presentScene(Game4(fileNamed: "Game4")!, transition: .fade(withDuration: 1.0))
        } else if AdventureLevel == 5 && AdventureStage == 8 {
            if !muteSound {
                run(.playSoundFileNamed("win.mp3", waitForCompletion: false))
            }
            view!.presentScene(GameScene(fileNamed: "GameScene")!, transition: .fade(withDuration: 2.0))
        } else {
            AdventureStage += 1
            if !muteSound {
                run(shootSoundAction)
            }
            view!.presentScene(GameAdventureController(fileNamed: "Adventure\(AdventureLevel)-\(AdventureStage)")!, transition: .fade(withDuration: 0.4))
        }
    }
    
    override func didMove(to view: SKView) {
        run(.run({bgm.volume = 0}))
        (childNode(withName: "SKReferenceNode_0") as! SKReferenceNode).resolve()
        localizeLabelsInScene(self)
    }
    
    override func mouseDown(with theEvent: NSEvent) {
        let point = theEvent.location(in: self)
        
        clickedButton = .none
        
        if point.y <= 64 {
            switch point.x {
            case 1...192:
                clickedButton = .mainMenu
                childNode(withName: "//MainMenu")!.alpha = 0.5
            case 832...1024:
                clickedButton = .watchAgain
                childNode(withName: "//WatchAgain")!.alpha = 0.5
            default: continueAction()
            }
        }
    }
    
    override func mouseUp(with theEvent: NSEvent) {
        let point = theEvent.location(in: self)
        if point.y <= 64 {
            switch point.x {
            case 1...192:
                if clickedButton == .mainMenu {
                    view!.presentScene(GameScene(fileNamed: "GameScene")!, transition: .fade(withDuration: 2.0))
                }
            case 832...1024:
                if clickedButton == .watchAgain {
                    AdventureStage = 1
                    if !muteSound {
                        run(.playSoundFileNamed("respawn.mp3", waitForCompletion: false))
                    }
                    restartAction(inScene: self)
                }
            default: continueAction()
            }
        } else if clickedButton == .none {
            continueAction()
        }
        
        clickedButton = .none
        childNode(withName: "//MainMenu")!.alpha = 1
        childNode(withName: "//WatchAgain")!.alpha = 1
    }
}

class GameAdventureOver: SKScene {
    
    enum buttons {
        case none
        case mainMenu
        case restartLevel
    }
    
    var clickedButton = buttons.none
    
    override func didMove(to view: SKView) {
        run(.run({bgm.volume = 0}))
    }
    
    override func mouseDown(with theEvent: NSEvent) {
        let point = theEvent.location(in: self)
        
        clickedButton = .none
        
        if point.x >= 384 && point.x <= 640 {
            switch point.y {
            case 128...255:
                clickedButton = .mainMenu
                childNode(withName: "MainMenu")!.alpha = 0.5
            case 256...383:
                clickedButton = .restartLevel
                childNode(withName: "RestartLevel")!.alpha = 0.5
            default: break
            }
        }
    }
    
    override func mouseUp(with theEvent: NSEvent) {
        let point = theEvent.location(in: self)
        if point.x >= 384 && point.x <= 640 {
            switch point.y {
            case 128...255:
                if clickedButton == .mainMenu {
                    view!.presentScene(GameScene(fileNamed: "GameScene")!, transition: .fade(withDuration: 2.0))
                }
            case 256...383:
                if clickedButton == .restartLevel {
                    AdventureStage = 1
                    if !muteSound {
                        run(.playSoundFileNamed("respawn.mp3", waitForCompletion: false))
                    }
                    restartAction(inScene: self)
                }
            default: break
            }
        }
        
        clickedButton = .none
        childNode(withName: "MainMenu")!.alpha = 1
        childNode(withName: "RestartLevel")!.alpha = 1
    }
}

