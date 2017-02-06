//
//  TitleScene.swift
//  SimpleShooterGame
//
//  Created by Andy Wu on 2/1/17.
//  Copyright © 2017 Andy Wu. All rights reserved.
//

import Foundation
import SpriteKit

class TitleScene : SKScene {
    
    var btnPlay: UIButton!
    var gameTitle: UILabel!
    
    var textColorHUD = UIColor(colorLiteralRed: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)
    
    override func didMove(to view: SKView) {
        self.backgroundColor = UIColor.purple
        
        setupText()
    }
    
    func setupText() {
        btnPlay = UIButton(frame: CGRect(x: 100, y: 100, width: 400, height: 100))
        btnPlay.center = CGPoint(x: (view?.frame.size.width)! / 2, y: (view?.frame.size.height)! / 2)
        btnPlay.titleLabel?.font = UIFont(name: "Futura", size: 60)
        btnPlay.setTitle("Play!", for: UIControlState.normal)
        btnPlay.setTitleColor(textColorHUD, for: UIControlState.normal)
        btnPlay.addTarget(self, action: #selector(TitleScene.playTheGame), for: UIControlEvents.touchUpInside)
        self.view?.addSubview(btnPlay)
        
        gameTitle = UILabel(frame: CGRect(x: 0, y: 0, width: view!.frame.width, height: 300))
        
        gameTitle.textColor = textColorHUD
        gameTitle.font = UIFont(name: "Futura", size: 40)
        gameTitle.textAlignment = NSTextAlignment.center
        gameTitle.text = "Space Shooter"
        self.view?.addSubview(gameTitle)
    }
    
    func playTheGame(){
        self.view?.presentScene(GameScene(), transition: SKTransition.crossFade(withDuration: 1.0))
        
        btnPlay.removeFromSuperview()
        gameTitle.removeFromSuperview()
        
        if let scene = GameScene(fileNamed: "GameScene") {
            let skView = self.view! as SKView
            skView.ignoresSiblingOrder = true
            scene.size = (view?.bounds.size)!
            scene.scaleMode = .resizeFill
            skView.presentScene(scene)
            
        }
    }
    
}
