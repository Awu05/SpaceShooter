//
//  GameScene.swift
//  SimpleShooterGame
//
//  Created by Andy Wu on 1/27/17.
//  Copyright © 2017 Andy Wu. All rights reserved.
//

import SpriteKit
import GameplayKit

var player = SKSpriteNode()
var projectile = SKSpriteNode()
var enemy = SKSpriteNode()

var scoreLabel = SKLabelNode()
var mainLabel = SKLabelNode()

var fireProjectileRate = 0.2
var projectileSpeed = 0.9

var enemySpeed = 5.0
var enemySpawnRate = 0.6

var isAlive = true

var score = 0

var textColorHUD = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)

struct physicsCategory {
    static let player: UInt32 = 1
    static let enemy: UInt32 = 2
    static let projectile: UInt32 = 3
}


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        
        self.backgroundColor = UIColor.purple
        
        spawnPlayer()
        spawnScoreLabel()
        spawnMainLabel()
        spawnProjectile()
        fireProjectile()
        spawnEnemy()
        randomEnemyTimerSpawn()
        updateScore()
        hideLabel()
        resetVariablesOnStart()
        
        
    }
    
    
    func touchDown(atPoint pos : CGPoint) {
        
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        
    }
    
    func touchUp(atPoint pos : CGPoint) {
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let touchLocation = touch.location(in: self)
            
            if isAlive {
                player.position.x = touchLocation.x
            }
            
            if !isAlive {
                player.position.x = -1000
            }
            
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if !isAlive {
            player.position.x = -1000
        }
        
        if score == 10 {
            enemySpeed = 2.0
            enemySpawnRate = 0.2
        } else if score >= 20 {
            enemySpeed = 1.0
            enemySpawnRate = 0.1
        }
    }
    
    func spawnPlayer(){
        player = SKSpriteNode(imageNamed: "Player")
        //player = SKSpriteNode(color: .white, size: CGSize(width: 40, height: 40))
        player.position = CGPoint(x: self.frame.midX, y: ((view?.frame.size.height)! * -0.5) + 130)
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody?.affectedByGravity = false
        player.physicsBody?.categoryBitMask = physicsCategory.player
        player.physicsBody?.contactTestBitMask = physicsCategory.enemy
        player.physicsBody?.isDynamic = false
        
        self.addChild(player)
        
    }
    
    func spawnScoreLabel(){
        scoreLabel = SKLabelNode(fontNamed: "Futura")
        scoreLabel.fontSize = 50
        scoreLabel.fontColor = textColorHUD
        scoreLabel.position = CGPoint(x: self.frame.midX, y: ((view?.frame.size.height)! * -0.5) + 20)
        
        scoreLabel.text = "Score"
        
        self.addChild(scoreLabel)
    }
    
    func spawnMainLabel(){
        mainLabel = SKLabelNode(fontNamed: "Futura")
        mainLabel.fontSize = 100
        mainLabel.fontColor = textColorHUD
        mainLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        mainLabel.text = "Start"
        
        self.addChild(mainLabel)
    }
    
    func spawnProjectile(){
        projectile = SKSpriteNode(imageNamed: "Projectile")
        //projectile = SKSpriteNode(color: .white , size: CGSize(width: 10, height: 10))
        projectile.position = CGPoint(x: player.position.x, y: player.position.y)
        
        projectile.physicsBody = SKPhysicsBody(rectangleOf: projectile.size)
        projectile.physicsBody?.affectedByGravity = false
        projectile.physicsBody?.categoryBitMask = physicsCategory.projectile
        projectile.physicsBody?.contactTestBitMask = physicsCategory.enemy
        projectile.physicsBody?.isDynamic = false
        projectile.zPosition = -1
        
        let moveForward = SKAction.moveTo(y: 1000, duration: projectileSpeed)
        
        let destroy = SKAction.removeFromParent()
        
        projectile.run(SKAction.sequence([moveForward, destroy]))
        
        self.addChild(projectile)
    }
    
    func spawnEnemy() {
        enemy = SKSpriteNode(imageNamed: "Enemy")
        let ranNegXPos = (Int(arc4random_uniform(UInt32(self.frame.width))) * -1 )
        let ranPositXPos = Int(arc4random_uniform(UInt32(self.frame.width)))
        
        //enemy = SKSpriteNode(color: .red, size: CGSize(width: 30, height: 30))
        enemy.position = CGPoint(x: ranNegXPos + ranPositXPos, y: 500)
        
        enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.size)
        enemy.physicsBody?.affectedByGravity = false
        enemy.physicsBody?.categoryBitMask = physicsCategory.enemy
        enemy.physicsBody?.contactTestBitMask = physicsCategory.projectile
        enemy.physicsBody?.allowsRotation = false
        enemy.physicsBody?.isDynamic = true
        
        var moveForward = SKAction.moveTo(y: (self.frame.size.height + 100) * -1, duration: enemySpeed)
        let destroy = SKAction.removeFromParent()
        
        enemy.run(SKAction.sequence([moveForward, destroy]))
        
        if isAlive == false {
            moveForward = SKAction.moveTo(y: 2000, duration: 1.0)
        }
        
        self.addChild(enemy)
    }
    
    func spawnExplosion(enemyTemp: SKSpriteNode) {
        let explosionEmitterPath:String = Bundle.main.path(forResource: "Explosion", ofType:"sks")!
        
        let explosion = NSKeyedUnarchiver.unarchiveObject(withFile: explosionEmitterPath) as! SKEmitterNode
        
        explosion.position = CGPoint(x: enemyTemp.position.x, y: enemyTemp.position.y)
        
        explosion.zPosition = 1
        explosion.targetNode = self
        
        self.addChild(explosion)
        
        let explosionTimerRemove = SKAction.wait(forDuration: 1.0)
        
        let removeExplosion = SKAction.run {
            explosion.removeFromParent()
        }
        
        self.run(SKAction.sequence([explosionTimerRemove, removeExplosion]))
    }
    
    func fireProjectile(){
        let fireProjectileTimer = SKAction.wait(forDuration: fireProjectileRate)
        
        let spawn = SKAction.run {
            self.spawnProjectile()
        }
        
        let sequence = SKAction.sequence([fireProjectileTimer, spawn])
        
        self.run(SKAction.repeatForever(sequence))
    }
    
    func randomEnemyTimerSpawn(){
        let spawnEnemyTimer = SKAction.wait(forDuration: enemySpawnRate)
        
        let spawn = SKAction.run {
            self.spawnEnemy()
        }
        
        let sequence = SKAction.sequence([spawnEnemyTimer, spawn])
        
        self.run(SKAction.repeatForever(sequence))
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody: SKPhysicsBody = contact.bodyA
        let secondBody: SKPhysicsBody = contact.bodyB
        
        if (((firstBody.categoryBitMask == physicsCategory.projectile) && (secondBody.categoryBitMask == physicsCategory.enemy)) || ((firstBody.categoryBitMask == physicsCategory.enemy) && (secondBody.categoryBitMask == physicsCategory.projectile))) {
            
            spawnExplosion(enemyTemp: firstBody.node as! SKSpriteNode)
            
            projectileCollision(enemyTemp: firstBody.node as! SKSpriteNode, protectileTemp: secondBody.node as! SKSpriteNode)
        }
        
        if (((firstBody.categoryBitMask == physicsCategory.enemy) && (secondBody.categoryBitMask == physicsCategory.player)) || ((firstBody.categoryBitMask == physicsCategory.player) && (secondBody.categoryBitMask == physicsCategory.enemy))) {
            
            enemyPlayerCollision(enemyTemp: firstBody.node as! SKSpriteNode, playerTemp: secondBody.node as! SKSpriteNode)
        }
    }
    
    func projectileCollision(enemyTemp: SKSpriteNode, protectileTemp: SKSpriteNode){
        enemyTemp.removeFromParent()
        protectileTemp.removeFromParent()
        
        score += 1
        
        updateScore()
    }
    
    func enemyPlayerCollision(enemyTemp: SKSpriteNode, playerTemp: SKSpriteNode){
        mainLabel.fontSize = 50
        mainLabel.alpha = 1.0
        mainLabel.text = "Game Over"
        
        player.removeFromParent()
        
        isAlive = false
        
        waitThenMoveToTitleScreen()
    }
    
    func waitThenMoveToTitleScreen(){
        let wait = SKAction.wait(forDuration: 3.0)
        let transition = SKAction.run {
            self.view?.presentScene(TitleScene(), transition: SKTransition.crossFade(withDuration: 0.3))
        }
        
        let sequence = SKAction.sequence([wait, transition])
        
        self.run(SKAction.repeat(sequence, count: 1))
    }
    
    func updateScore(){
        scoreLabel.text = "Score: \(score)"
    }
    
    func hideLabel(){
        let wait = SKAction.wait(forDuration: 3.0)
        let hide = SKAction.run {
            mainLabel.alpha = 0.0
        }
        
        let sequence = SKAction.sequence([wait, hide])
        
        self.run(SKAction.repeat(sequence, count: 1))
    }
    
    func resetVariablesOnStart(){
        isAlive = true
        score = 0
        
        enemySpeed = 5.0
        enemySpawnRate = 0.6
    }
}
