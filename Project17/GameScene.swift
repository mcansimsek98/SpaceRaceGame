//
//  GameScene.swift
//  Project17
//
//  Created by Mehmet Can Şimşek on 26.07.2022.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
 
    var starfield: SKEmitterNode!
    var player: SKSpriteNode!
    
    var scoreLabel: SKLabelNode!
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var possibleEnemies = ["ball", "hammer", "tv"]
    
    var isGameOver = false
    
    var gameTimer: Timer?
    var enemyTimeInterval: Double = 0.8
    var enemiesGenerated: Int = 0
    
    override func didMove(to view: SKView) {
        
        backgroundColor = .black
        
        starfield = SKEmitterNode(fileNamed: "starfield")!
        starfield.position = CGPoint(x: 1024, y: 384)
        starfield.advanceSimulationTime(10)
        addChild(starfield)
        starfield.zPosition = -1
        
        
        player = SKSpriteNode(imageNamed: "player")
        player.position = CGPoint(x: 100, y: 384)
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.size)
        player.physicsBody?.contactTestBitMask = 1
        addChild(player)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.position = CGPoint(x: 16, y: 16)
        scoreLabel.horizontalAlignmentMode = .left
        addChild(scoreLabel)
        
        score = 0
        
        //yerçekimi ayarları
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
        
        
       timer()
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        var location = touch.location(in: self)
        
        if location.y < 100 {
            location.y = 100
        }else if location.y > 668 {
            location.y = 668
        }
        player.position = location
        
    }
    func didBegin(_ contact: SKPhysicsContact) {
        gameOver()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        gameOver()
    }
    
    
    @objc func createEnemy() {
        guard let enemy = possibleEnemies.randomElement() else { return }
        
        let sprite = SKSpriteNode(imageNamed: enemy)
        sprite.position = CGPoint(x: 1200, y: Int.random(in: 50...736))
        addChild(sprite)
        
        sprite.physicsBody = SKPhysicsBody(texture: sprite.texture!, size: sprite.size)
        sprite.physicsBody?.categoryBitMask = 1
        sprite.physicsBody?.velocity = CGVector(dx: -500, dy: 0)
        sprite.physicsBody?.angularVelocity = 5
        sprite.physicsBody?.linearDamping = 0
        sprite.physicsBody?.angularDamping = 0
        
        enemiesGenerated += 1
        if enemiesGenerated.isMultiple(of: 20) {
            enemyTimeInterval -= 0.1
            timer()
        }
        
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        for node in children {
            if node.position.x < -300 {
                node.removeFromParent()
            }
        }
       if !isGameOver {
            score += 1
        }

    }
    
    func gameOver() {
        let explosion = SKEmitterNode(fileNamed: "explosion")!
        explosion.position = player.position
        addChild(explosion)
        player.removeFromParent()
        gameTimer?.invalidate()
        isGameOver = true
        alert()
    }
    
    func alert() {
        let ac = UIAlertController(title: "Game Over", message: "Do you want to play again?", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Play again", style: .default, handler: { _ in
            self.isGameOver = false
            self.createEnemy()
            self.score = 0
            self.timer()
            self.player.position = CGPoint(x: 100, y: 384)
            self.addChild(self.player)
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.view?.window?.rootViewController?.present(ac, animated: true)
    }
        
    
    func timer() {
        gameTimer?.invalidate()
        gameTimer = Timer.scheduledTimer(timeInterval: enemyTimeInterval, target: self, selector: #selector(createEnemy), userInfo: nil, repeats: true)
    }

}
