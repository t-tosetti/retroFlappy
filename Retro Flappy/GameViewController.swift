//
//  GameViewController.swift
//  Retro Flappy
//
//  Created by Thiago Tosetti Lopes on 01/03/16.
//  Copyright © 2016 Thiago Tosetti Lopes. All rights reserved.
//

import UIKit
import SpriteKit
import AVFoundation

var stage:SKView!
var proportion:CGFloat!
var gameWidth:CGFloat = 320.0
var musicPlayer:AVAudioPlayer!

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        stage = self.view as! SKView
        stage.ignoresSiblingOrder = true
        proportion = stage.bounds.size.height / stage.bounds.size.width
        
        let scene = GameScene(size: CGSize(width: gameWidth, height: gameWidth*proportion))
        scene.scaleMode = .AspectFill
        stage.presentScene(scene)
        
        playBackgroundMusic()

    }

    func playBackgroundMusic() {
        if let urlMusic = NSBundle.mainBundle().URLForResource("music", withExtension: "wav") {
            var bgError:ErrorType!
            do {
                musicPlayer = try AVAudioPlayer(contentsOfURL: urlMusic)
            } catch {
                bgError = error
            }
            if bgError == nil {
                musicPlayer.numberOfLoops = -1
                musicPlayer.volume = 0.5
                musicPlayer.play()
            }
        }
    }
    
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    

}
