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
    
    override func didMoveToView(view: SKView) {
        physicsWorld.contactDelegate = self
        sceneSetup()
        setupPlayer()
        spawnObstacles()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        let touch = touches.first!
        let touchLocation = touch.locationInNode(self)
        
        let moveTo = SKAction.moveTo(touchLocation, duration: 1.0)
        satellite.runAction(moveTo)
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
    
    func didBeginContact(contact: SKPhysicsContact) {
        let victims = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
    
        switch victims {
        case bitMask.satellite.rawValue | bitMask.asteroid.rawValue:
            contact.bodyA.node?.removeFromParent()
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
        let waitForOneMinute = SKAction.waitForDuration(1.0)
        let spawnSequence = SKAction.sequence([spawnRandomAsteroid, waitForOneMinute])
        let continuousSpawn = SKAction.repeatActionForever(spawnSequence)
        runAction(continuousSpawn)
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
        
        addChild(asteroid)
    }
    
}
