//
//  GameMenuScene.swift
//  Finder Zen 2
//
//  Created by Vince14Genius on 4/18/16.
//  Copyright © 2016 Vince14Genius. All rights reserved.
//

import SpriteKit

let menu = SKNode(fileNamed: "GameMenuScene")!.childNode(withName: "menu")!
let menuMuteMusicButton = menu.childNode(withName: "MuteMusic")!
let menuMuteSoundButton = menu.childNode(withName: "MuteSound")!
let menuPlayButton = menu.childNode(withName: "ButtonPlay")!
let menuHomeButton = menu.childNode(withName: "ButtonHome")!

enum menuButtons {
    case none
    case playButton
    case homeButton
    case muteMusicButton
    case muteSoundButton
}

var menuClickedButton = menuButtons.none

//Three functions for showing and hiding the pause menu.

func turnMenuOn() {
    if !menuOn {
        menu.alpha = 0
    }
 
    menuOn = true
    bgm.pause()
    
    leftQueue = false
    rightQueue = false
    upQueue = false
    downQueue = false
    
    for child in currentScene.children {
        if !(child === menu) {
            child.isPaused = true
        }
    }
    
    menuMuteMusicButton.children[0].isHidden = !muteMusic
    menuMuteSoundButton.children[0].isHidden = !muteSound
    menu.zPosition = 20
    menu.removeFromParent()
    
    (menu.childNode(withName: "TextPaused") as! SKLabelNode).text = NSLocalizedString("TextPaused", comment: "")
    
    if let _ = menu.parent {
        menu.removeFromParent()
    }
    currentScene.addChild(menu)
    
    menu.run(.fadeIn(withDuration: 0.25))
}

func turnMenuOff() {
    bgm.play()
    menuOn = false
    
    menu.run(.sequence([.fadeOut(withDuration: 0.75), .run({
        menuOn = false
        
        for child in currentScene.children {
            child.isPaused = false
        }
        
    }), .removeFromParent()]))
}

func turnMenuOffImmediately() {
    bgm.play()
    menuOn = false
    menu.alpha = 0
    menu.removeFromParent()
}

//Two more functions to handle click events in the menu.
//menuInputBegan is equivalent to mouseDown and touchesBegan
//menuInputEnded is equivalent to mouseUp and touchesEnded

func menuInputBegan(_ node: SKNode) {
    menuClickedButton = .none
    
    if node === menuPlayButton {
        menuClickedButton = .playButton
        menuPlayButton.alpha = 0.5
    } else if node === menuHomeButton {
        menuClickedButton = .homeButton
        menuHomeButton.alpha = 0.5
    } else if node === menuMuteMusicButton || node.parent === menuMuteMusicButton {
        menuClickedButton = .muteMusicButton
        menuMuteMusicButton.alpha = 0.5
    } else if node === menuMuteSoundButton || node.parent === menuMuteSoundButton {
        menuClickedButton = .muteSoundButton
        menuMuteSoundButton.alpha = 0.5
    }
}

func menuInputEnded(_ node: SKNode) {
    if node === menuPlayButton && menuClickedButton == .playButton {
        turnMenuOff()
    } else if node === menuHomeButton && menuClickedButton == .homeButton {
        turnMenuOffImmediately()
        currentScene.run(.playSoundFileNamed("respawn.mp3", waitForCompletion: false))
        currentScene.view!.presentScene(GameScene(fileNamed: "GameScene")!, transition: .push(with: .right, duration: 0.5))
    } else if (node === menuMuteMusicButton || node.parent === menuMuteMusicButton) && menuClickedButton == .muteMusicButton {
        muteMusic = !muteMusic
        standardDefaults.set(muteMusic, forKey: "muteMusic")
        menuMuteMusicButton.children[0].isHidden = !muteMusic
    } else if (node === menuMuteSoundButton || node.parent === menuMuteSoundButton) && menuClickedButton == .muteSoundButton {
        muteSound = !muteSound
        standardDefaults.set(muteSound, forKey: "muteSound")
        menuMuteSoundButton.children[0].isHidden = !muteSound
    }
    
    menuClickedButton = .none
    menuPlayButton.alpha = 1
    menuHomeButton.alpha = 1
    menuMuteMusicButton.alpha = 1
    menuMuteSoundButton.alpha = 1
}
