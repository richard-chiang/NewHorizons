//
//  GameScene.swift
//  NewHorizons
//
//  Created by RichardChiang on 2016-07-06.
//  Copyright (c) 2016 RichardChiang. All rights reserved.
//

import SpriteKit
import UIKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    enum bitMask: UInt32 {
        case none = 0
        case satellite = 1
        case asteroid = 2
        case frame = 4
    }
    
    let satellite = SKSpriteNode(imageNamed: "sat2")
    
    var missionDurationLabel = SKLabelNode(text: "Mission Duration")
    var missionMinuteLabel = SKLabelNode(text: "Minute")
    var missionHourLabel = SKLabelNode(text: "Hour")
    var missionDayLabel = SKLabelNode(text: "Day")
    
    var day = 0
    var hour = 0
    var minute = 0
    var minuteTimeLabel = SKLabelNode(text: "0")
    var hourTimeLabel = SKLabelNode(text: "0")
    var dayTimeLabel = SKLabelNode(text: "0")
    
    var dodgedAsteroids = 0
    var asteroidsDodgedCountLabel = SKLabelNode(text: "0")
    var asteroidsDodgedLabel = SKLabelNode(text: "Asteroids dodged")
    var asteroidsDodgedImage = SKSpriteNode(imageNamed: "AsteroidsDodged")
    
    let playButton = SKSpriteNode(imageNamed: "playButton")
    let pauseButton = SKSpriteNode(imageNamed: "pause")
    
    override func didMoveToView(view: SKView) {
        physicsWorld.contactDelegate = self
        sceneSetup()
        setupPlayer()
        spawnObstacles()
        startMissionTime()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch begins */
        let touch = touches.first!
        let touchLocation = touch.locationInNode(self)
        let node = nodeAtPoint(touchLocation)
        
        if let name = node.name {
            switch name {
            case "pauseButton":
                pauseGame()
                showPlayButton()
            case "playButton":
                showPauseButton()
                resumeGame()
            default:
                let moveTo = SKAction.moveTo(touchLocation, duration: 1.0)
                satellite.runAction(moveTo)
            }
            
        }
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        enumerateChildNodesWithName("Asteroid") {
            asteroid, _ in
            
            if asteroid.position.y <= 3 {
                self.dodgedAsteroids++
                self.asteroidsDodgedCountLabel.text = "\(self.dodgedAsteroids)"
                asteroid.removeFromParent()
            }
        }
    }
    
    
    func didBeginContact(contact: SKPhysicsContact) {
        let victims = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        switch victims {
        case bitMask.satellite.rawValue | bitMask.asteroid.rawValue:
            contact.bodyA.node?.removeFromParent()
            removeActionForKey("missionDurationTime")
            removeActionForKey("spawnAsteroid")
            enumerateChildNodesWithName("Asteroid") { (asteroid, _) in
                asteroid.name = "dontCountMe"
            }
        default:
            break
        }
    }
    
    // HELPER ===========
    
    func randomNumber(min min: CGFloat, max: CGFloat) -> CGFloat {
        let random = CGFloat(Float(arc4random()) / 0xFFFFFFFF)
        return random * (max - min) + min
    }
    
    // add scene modification
    func sceneSetup() {
        backgroundColor = UIColor.blackColor()
        physicsWorld.gravity = CGVectorMake(0, -0.9)
        
        missionDurationLabel.fontColor = UIColor.redColor()
        missionDurationLabel.fontSize = 30
        missionDurationLabel.fontName = "Helvetica Neue"
        missionDurationLabel.position = CGPoint(x: frame.size.width / 2, y: frame.size.height - 45)
        addChild(missionDurationLabel)
        
        missionMinuteLabel.fontSize = 30
        missionMinuteLabel.fontName = "Helvetica Neue"
        missionMinuteLabel.position = CGPoint(x: frame.size.width / 2 + 150, y: frame.size.height - 85)
        addChild(missionMinuteLabel)
        
        missionHourLabel.fontSize = 30
        missionHourLabel.fontName = "Helvetica Neue"
        missionHourLabel.position = CGPoint(x: frame.size.width / 2, y: frame.size.height - 85)
        addChild(missionHourLabel)
        
        missionDayLabel.fontSize = 30
        missionDayLabel.fontName = "Helvetica Neue"
        missionDayLabel.position = CGPoint(x: frame.size.width / 2 - 150, y: frame.size.height - 85)
        addChild(missionDayLabel)
        
        minuteTimeLabel.fontSize = 30
        minuteTimeLabel.fontName = "Helvetica Neue"
        minuteTimeLabel.position = CGPoint(x: frame.size.width / 2 + 150, y: frame.size.height - 120)
        addChild(minuteTimeLabel)
        
        hourTimeLabel.fontSize = 30
        hourTimeLabel.fontName = "Helvetica Neue"
        hourTimeLabel.position = CGPoint(x: frame.size.width / 2, y: frame.size.height - 120)
        addChild(hourTimeLabel)
        
        dayTimeLabel.fontSize = 30
        dayTimeLabel.fontName = "Helvetica Neue"
        dayTimeLabel.position = CGPoint(x: frame.size.width / 2 - 150, y: frame.size.height - 120)
        addChild(dayTimeLabel)
        
        asteroidsDodgedImage.position = CGPoint(x: frame.size.width / 5.7, y: frame.size.height - 700)
        addChild(asteroidsDodgedImage)
        
        asteroidsDodgedLabel.fontSize = 28
        asteroidsDodgedLabel.fontName = "Helvetica Neue"
        asteroidsDodgedLabel.position = CGPoint(x: frame.size.width / 4.7, y: frame.size.height - 750)
        asteroidsDodgedLabel.zPosition = 1
        addChild(asteroidsDodgedLabel)
        
        asteroidsDodgedCountLabel.fontSize = 30
        asteroidsDodgedCountLabel.fontName = "Helvetica Neue"
        asteroidsDodgedCountLabel.position = CGPoint(x: frame.size.width / 15.5, y: frame.size.height - 700)
        asteroidsDodgedCountLabel.zPosition = 1
        addChild(asteroidsDodgedCountLabel)
        
        pauseButton.name = "pauseButton"
        pauseButton.zPosition = 1
        pauseButton.position = CGPoint(x: frame.size.width * 0.94, y: frame.size.height - 80)
        addChild(pauseButton)
        
        playButton.name = "playButton"
        playButton.zPosition = 1
        playButton.position = CGPoint(x: frame.size.width * 0.94, y: frame.size.height - 80)
        playButton.hidden = true
        addChild(playButton)
    }
    
    // setup player here
    func setupPlayer() {
        satellite.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        satellite.physicsBody = SKPhysicsBody(texture: satellite.texture!, size: satellite.frame.size)
        
        if let body = satellite.physicsBody {
            body.dynamic = false
            body.affectedByGravity = false
            body.allowsRotation = false
            body.categoryBitMask = bitMask.satellite.rawValue
            body.contactTestBitMask = bitMask.asteroid.rawValue
            body.collisionBitMask = bitMask.frame.rawValue
        }
        
        addChild(satellite)
    }
    
    // add game obstacles here
    func spawnObstacles() {
        generateAsteroids()
    }
    
    func generateAsteroids() {
        let spawnRandomAsteroid = SKAction.runBlock(spawnAsteroid)
        let waitForOneSecond = SKAction.waitForDuration(1.0)
        let spawnSequence = SKAction.sequence([spawnRandomAsteroid, waitForOneSecond])
        let continuousSpawn = SKAction.repeatActionForever(spawnSequence)
        runAction(continuousSpawn, withKey: "spawnAsteroid")
    }
    
    func spawnAsteroid() {
        let asteroid = SKSpriteNode(imageNamed: "asteroid")
        let posX = randomNumber(min: 0, max: frame.size.width)
        let posY = frame.size.height + asteroid.size.height
        asteroid.position = CGPoint(x: posX, y: posY)
        asteroid.physicsBody = SKPhysicsBody(circleOfRadius: asteroid.frame.size.width * 0.3)
        if let body = asteroid.physicsBody {
            body.categoryBitMask = bitMask.asteroid.rawValue
            body.contactTestBitMask = bitMask.satellite.rawValue
        }
        asteroid.name = "Asteroid"
        addChild(asteroid)
    }
    
    func startMissionTime() {
        let updateMissionTimeLabel = SKAction.runBlock(updateMissionTime)
        let waitForOneSecond = SKAction.waitForDuration(1.0)
        let updateTimeSequence = SKAction.sequence([updateMissionTimeLabel, waitForOneSecond])
        let timer = SKAction.repeatActionForever(updateTimeSequence)
        runAction(timer, withKey: "missionDurationTime")
    }
    
    func updateMissionTime() {
        minute++
        
        if minute == 60 {
            hour++
            minute = 0
        }
        
        if hour == 24 {
            day++
            hour = 0
        }
        
        minuteTimeLabel.text = "\(minute)"
        hourTimeLabel.text = "\(hour)"
        dayTimeLabel.text = "\(day)"
    }
    
    func pauseGame() {
        view!.paused = true
    }
    
    func showPlayButton() {
        pauseButton.hidden = true
        playButton.hidden = false
    }
    
    func resumeGame() {
        view!.paused = false
    }
    
    func showPauseButton() {
        playButton.hidden = true
        pauseButton.hidden = false
    }
    
}
