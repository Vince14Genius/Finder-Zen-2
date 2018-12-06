//
//  AppDelegate.swift
//  Finder Zen 2
//
//  Created by Vince14Genius on 9/8/15.
//  Copyright © 2015 Vince14Genius. All rights reserved.
//


import Cocoa
import SpriteKit
import AVFoundation

let pausedbg = SKSpriteNode(texture: SKTexture(imageNamed: "pausedbg"), size: CGSize(width: 1024, height: 768))

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var skView: SKView!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        /* Pick a size for the scene */
        if let scene = GameScene(fileNamed:"GameScene") {
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .aspectFill
            self.skView!.ignoresSiblingOrder = true
            
            self.skView!.presentScene(scene)
            
            self.skView!.showsFPS = true
        }
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    func gamePause() {
        if skView.scene!.isKind(of: Game1.self) || skView.scene!.isKind(of: Game2.self) || skView.scene!.isKind(of: Game3.self) || skView.scene!.isKind(of: Game4.self) {
            turnMenuOn()
        } else {
            skView.scene?.isPaused = true
            bgm.pause()
        }
    }
    
    func applicationDidResignActive(_ notification: Notification) {
        gamePause()
    }
    
    func applicationDidHide(_ notification: Notification) {
        gamePause()
    }
    
    func applicationDidBecomeActive(_ notification: Notification) {
        if !(skView.scene!.isKind(of: Game1.self) || skView.scene!.isKind(of: Game2.self) || skView.scene!.isKind(of: Game3.self) || skView.scene!.isKind(of: Game4.self)) {
            skView.scene?.isPaused = false
            bgm.play()
        }
    }
}
