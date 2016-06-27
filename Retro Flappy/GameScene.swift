//
//  GameScene.swift
//  Retro Flappy
//
//  Created by Thiago Tosetti Lopes on 01/03/16.
//  Copyright © 2016 Thiago Tosetti Lopes. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    private var floor:SKSpriteNode!
    private let gameArea:CGFloat = 410.0
    private var intro:SKSpriteNode!
    private var player:SKSpriteNode!
    private let speedy:Double = 100.0
    private var startedGame:Bool = false
    private var endedGame:Bool = false
    private var restart:Bool = false
    private var scoreText = SKLabelNode()
    private var score:Int = 0
    private let forceJump:CGFloat = 20.0
    private var timer:NSTimer!
    
    private let playerCategory:UInt32 = 1
    private let obstacleCategory:UInt32 = 2
    private let pointingCategory:UInt32 = 4
    
    private var crashSound = SKAction.playSoundFileNamed("crash.mp3", waitForCompletion: false)
    private var pointingSound = SKAction.playSoundFileNamed("pointing.mp3", waitForCompletion: false)
    private var jumpSound = SKAction.playSoundFileNamed("jump.mp3", waitForCompletion: false)
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(size: CGSize) {
        super.init(size: size)
    }
    
    override func didMoveToView(view: SKView) {
        self.physicsWorld.contactDelegate = self
        addBackground()
        addFloor()
        addIntro()
        addPlayer()
        moveFloor()
    }
    
    private func addBackground() {
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: size.width/2, y: size.height - background.size.height/2)
        background.zPosition = 0
        addChild(background)
    }
    
    private func addFloor() {
        floor = SKSpriteNode(imageNamed: "floor")
        floor.position = CGPoint(x: size.width, y: size.height - floor.size.height/2 - gameArea)
        floor.zPosition = 2
        addChild(floor)
        
        let roof = SKNode()
        roof.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: gameWidth, height: 1))
        roof.physicsBody?.dynamic = false
        roof.position = CGPoint(x: size.width/2, y: size.height)
        roof.zPosition = 2
        addChild(roof)
        
        let pavement = SKNode()
        pavement.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: gameWidth, height: 1))
        pavement.physicsBody?.dynamic = false
        pavement.position = CGPoint(x: size.width/2, y: size.height - gameArea)
        pavement.zPosition = 2
        pavement.physicsBody?.categoryBitMask = obstacleCategory
        pavement.physicsBody?.contactTestBitMask = playerCategory
        addChild(pavement)
    }
    
    private func addIntro() {
        intro = SKSpriteNode(imageNamed: "Intro")
        intro.position = CGPoint(x: size.width/2, y: size.height - 210)
        intro.zPosition = 3
        addChild(intro)
    }
    
    private func addPlayer() {
        player = SKSpriteNode(imageNamed: "player")
        player.position = CGPoint(x: 60, y: size.height - gameArea/2)
        player.zPosition = 4
        addChild(player)
    }
    
    private func moveFloor() {
        let moveAction = SKAction.moveByX(-floor.size.width/2, y: 0, duration: Double(floor.size.width/2)/speedy)
        let replaceAction = SKAction.moveByX(floor.size.width/2, y: 0, duration: 0)
        let sequelAction = SKAction.sequence([moveAction, replaceAction])
        let repetitionAction = SKAction.repeatActionForever(sequelAction)
        floor.runAction(repetitionAction)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if !endedGame {
            if startedGame {
                player.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: forceJump))
                runAction(jumpSound)
            } else {
                intro.removeFromParent()
                addScore()
                
                player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width/2 - 10)
                player.physicsBody?.dynamic = true
                player.physicsBody?.allowsRotation = true
                player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: forceJump))
                
                player.physicsBody?.categoryBitMask = playerCategory
                player.physicsBody?.collisionBitMask = obstacleCategory
                player.physicsBody?.contactTestBitMask = pointingCategory
                
                timer = NSTimer.scheduledTimerWithTimeInterval(2.5, target: self, selector: "addPipe", userInfo: nil, repeats: true)
                
                startedGame = true
            }
        } else if restart {
            restartGame()
        }
    }
    
    func addScore() {
        scoreText.fontName = "PressStart2P"
        scoreText.fontSize = 50
        scoreText.text = "0"
        scoreText.position = CGPoint(x: size.width/2, y: size.height - 100)
        scoreText.fontColor = UIColor.grayColor()
        scoreText.zPosition = 5
        addChild(scoreText)
    }
    
    func addPipe() {
        let randomNumber = arc4random_uniform(132) + 74
        let distanceBetweenPipes = player.size.height*3
        
        let upPipe = SKSpriteNode(imageNamed: "upPipe")
        let pipeWidth = upPipe.size.width
        let pipeHeigth = upPipe.size.height
        
        upPipe.position = CGPoint(x: size.width + pipeWidth/2, y: size.height + pipeHeigth/2 - CGFloat(randomNumber))
        upPipe.zPosition = 1
        upPipe.physicsBody = SKPhysicsBody(rectangleOfSize: upPipe.size)
        upPipe.physicsBody?.dynamic = false
        upPipe.physicsBody?.categoryBitMask = obstacleCategory
        upPipe.physicsBody?.contactTestBitMask = playerCategory
        
        let downPipe = SKSpriteNode(imageNamed: "downPipe")
        downPipe.position = CGPoint(x: size.width + pipeWidth/2, y: upPipe.position.y - pipeHeigth - distanceBetweenPipes)
        downPipe.zPosition = 1
        downPipe.physicsBody = SKPhysicsBody(rectangleOfSize: downPipe.size)
        downPipe.physicsBody?.dynamic = false
        downPipe.physicsBody?.categoryBitMask = obstacleCategory
        downPipe.physicsBody?.contactTestBitMask = playerCategory
        
        let scorer = SKNode()
        scorer.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: 1, height: distanceBetweenPipes))
        scorer.position = CGPoint(x: upPipe.position.x + pipeWidth/2, y: upPipe.position.y - pipeHeigth/2 - distanceBetweenPipes/2)
        scorer.physicsBody?.dynamic = false
        scorer.physicsBody?.categoryBitMask = pointingCategory
        
        let distance = gameWidth + upPipe.size.width
        
        let moveAction = SKAction.moveByX(-distance, y: 0, duration: Double(distance)/speedy)
        let eraseAction = SKAction.removeFromParent()
        let sequelAction = SKAction.sequence([moveAction, eraseAction])
        
        upPipe.runAction(sequelAction)
        downPipe.runAction(sequelAction)
        scorer.runAction(sequelAction)
        
        addChild(upPipe)
        addChild(downPipe)
        addChild(scorer)
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        if startedGame {
            if contact.bodyA.categoryBitMask == pointingCategory || contact.bodyB.categoryBitMask == pointingCategory {
                score++
                runAction(pointingSound)
                scoreText.text = "\(score)"
            } else if contact.bodyA.categoryBitMask == obstacleCategory || contact.bodyB.categoryBitMask == obstacleCategory {
                runAction(crashSound)
                gameOver()
            }
        }
    }
    
    func gameOver() {
        timer.invalidate()
        player.zRotation = 0
        player.texture = SKTexture(imageNamed: "playerCrashed")
        for node in self.children {
            node.removeAllActions()
        }
        startedGame = false
        endedGame = true
        
        NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "showGameOver", userInfo: nil, repeats: false)
    }
    
    func showGameOver() {
        let textGameOver = SKLabelNode()
        textGameOver.fontName = "PressStart2P"
        textGameOver.fontColor = UIColor.grayColor()
        textGameOver.fontSize = 20
        textGameOver.text = "Game Over!"
        textGameOver.position = CGPoint(x: size.width/2, y: size.height/2 + 50)
        textGameOver.zPosition = 5
        let moveAction = SKAction.moveByX(0, y: 50, duration: 0.3)
        textGameOver.runAction(moveAction)
        addChild(textGameOver)
        restart = true
    }
    
    func restartGame() {
        let scene = GameScene(size: CGSize(width: gameWidth, height: gameWidth * proportion))
        scene.scaleMode = .AspectFill
        self.view!.presentScene(scene, transition: SKTransition.doorwayWithDuration(0.5))
    }
    
    override func update(currentTime: CFTimeInterval) {
    }
    
    
    
}
