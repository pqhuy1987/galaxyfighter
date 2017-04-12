//
//  GameScene.swift
//  Flappy Swift
//
//  Created by Julio Montoya on 13/07/14.
//  Copyright (c) 2015 Julio Montoya. All rights reserved.
//
//  Copyright (c) 2015 AvionicsDev
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//


import SpriteKit
import iAd
import AVFoundation
import Darwin
import Social
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


// Math Helpers
extension Float {
  static func clamp(_ min: CGFloat, max: CGFloat, value: CGFloat) -> CGFloat {
    if (value > max) {
      return max
    } else if (value < min) {
      return min
    } else {
      return value
    }
  }
    
  static func range(_ min: CGFloat, max: CGFloat) -> CGFloat {
    return CGFloat(Float(arc4random()) / 0xFFFFFFFF) * (max - min) + min
  }
}
public var backGroundMusic = AVAudioPlayer()
class GameScene: SKScene, SKPhysicsContactDelegate, ADInterstitialAdDelegate {
    var spaceship: SKSpriteNode!
    var boss: SKSpriteNode!
    var lastTouch: CGPoint? = nil
    let screenSize: CGRect = UIScreen.main.bounds
    var enemy_x: CGFloat = 0.0
    
    var currentLevel = 1
    var bossHealth = 0
    var bossTime = 0
    
    //difficulty
    var easy: SKSpriteNode!
    var medium: SKSpriteNode!
    var hard: SKSpriteNode!
    
    
    var missileNumber = Double()
    var enemyNumber = Double()
    
    
    
    var options: SKSpriteNode!
    var restart: SKSpriteNode!
    var share: SKSpriteNode!
    var soundON: SKSpriteNode!
    var soundOFF: SKSpriteNode!
    var close: SKSpriteNode!
    var resume: SKSpriteNode!
    // Background
    var background: SKNode!
    var background_speed = 100.0
    var hits = 0
    // Time Values
    var delta = TimeInterval(0)
    var last_update_time = TimeInterval(0)
    var pause: SKSpriteNode!
    var effectsPlayer = AVAudioPlayer()
    //var bossLaugh:NSURL = NSBundle.mainBundle().URLForResource("laugh", withExtension: "mp3")!
    var bgMusicUrl:URL = Bundle.main.url(forResource: "Reformat", withExtension: "mp3")!
    var laser:URL = Bundle.main.url(forResource: "laser", withExtension: "wav")!
    var ow:URL = Bundle.main.url(forResource: "ow", withExtension: "wav")!
    // Physics Categories
    let FSBoundaryCategory: UInt32 = 1 << 0
    let FSPlayerCategory: UInt32   = 1 << 1
    let FSPipeCategory: UInt32     = 1 << 2
    let FSGapCategory: UInt32      = 1 << 3
    let FSBossCategory: UInt32     = 1 << 4
    
    var heart1: SKSpriteNode!
    var heart2: SKSpriteNode!
    var heart3: SKSpriteNode!
    var volume = true
    var interstitialAd:ADInterstitialAd!
    var placeHolderView:UIView!
    var interstitialAdView: UIView = UIView()
    var num = 0.0
    var dead = false
    func interstitialAdDidUnload(_ interstitialAd: ADInterstitialAd!) {
        interstitialAdView.removeFromSuperview()
    }
    
    func interstitialAd(_ interstitialAd: ADInterstitialAd!, didFailWithError error: Error!) {
        
    }
    
    func interstitialAdDidLoad(_ interstitialAd: ADInterstitialAd!) {
        interstitialAdView = UIView()
        interstitialAdView.frame = self.view!.bounds
        self.view!.addSubview(interstitialAdView)
        
        interstitialAd.present(in: interstitialAdView)
        UIViewController.prepareInterstitialAds()
    }
    
    func interstitialAdActionDidFinish(_ interstitialAd: ADInterstitialAd!) {
        interstitialAdView.removeFromSuperview()
    }
    
    func interstitialAdActionShouldBegin(_ interstitialAd: ADInterstitialAd!, willLeaveApplication willLeave: Bool) -> Bool {
        return true
    }
    
    
    func interstitialAdWillLoad(_ interstitialAd: ADInterstitialAd!) {
        
    }
    enum FSGameState: Int {
        case fsGameStateStarting
        case fsGameStatePlaying
        case fsGameStateEnded
        case fsGameStateSetting
        case fsGameStatePaused
    }
    func playSound(_ soundVariable : SKAction)
    {
        
        SKAction.repeatForever(SKAction(run(soundVariable)))
        
    }
    // 2
    var state:FSGameState = .fsGameStateStarting
    
    var score = 0
    var highscore = 0
    var label_score: SKLabelNode!
    var label_highscore: SKLabelNode!
    var label_bossHealth: SKLabelNode!

  // MARK: - SKScene Initializacion
  override func didMove(to view: SKView) {
    
    if((UserDefaults.standard.object(forKey: "highscore") != nil)){
        
        highscore = UserDefaults.standard.object(forKey: "highscore") as! Int
        
        
    }
    backGroundMusic = try! AVAudioPlayer(contentsOf:bgMusicUrl)
    backGroundMusic.numberOfLoops = (-1)
    backGroundMusic.prepareToPlay()
    backGroundMusic.volume = 1.0
    effectsPlayer = try! AVAudioPlayer(contentsOf:laser)
    initWorld()
    initBackground()
    initHUD()
  }
    
  // MARK: - Init Physics
  func initWorld() {
    physicsWorld.contactDelegate = self
    physicsWorld.gravity = CGVector(dx: 0.0, dy: 0.0)
    // 2
    physicsBody = SKPhysicsBody(edgeLoopFrom: CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height))
    // 3
    physicsBody?.categoryBitMask = FSBoundaryCategory
    physicsBody?.collisionBitMask = FSPlayerCategory
  }

    func loadInterstitialAd() {
        interstitialAd = ADInterstitialAd()
        interstitialAd.delegate = self
    }
    let blink = SKAction.sequence([SKAction.fadeOut(withDuration: 0.2), SKAction.fadeIn(withDuration: 0.2)])
    
  // MARK: - Init spaceship
  func initSpaceship() {
    // 1
    spaceship = SKSpriteNode(imageNamed: "Spaceship1")
    // 2
    spaceship.name = "spaceship"
    spaceship.position = CGPoint(x: screenSize.width/2 , y: 0.0)
    // 3
    spaceship.physicsBody = SKPhysicsBody(circleOfRadius: spaceship.size.width / 2)
    spaceship.physicsBody?.categoryBitMask = FSPlayerCategory
    spaceship.physicsBody?.contactTestBitMask = FSPipeCategory | FSGapCategory | FSBoundaryCategory | FSBossCategory
    spaceship.physicsBody?.collisionBitMask = FSPipeCategory | FSBoundaryCategory | FSBossCategory
    spaceship.physicsBody?.allowsRotation = false
    spaceship.physicsBody?.restitution = 0.0
    spaceship.physicsBody?.mass = 0.225
    spaceship.zPosition = 50
    addChild(spaceship)
    run(SKAction.repeatForever(SKAction.sequence([SKAction.wait(forDuration: missileNumber), SKAction.run { self.initMissile()}])), withKey: "generator")
    run(SKAction.repeatForever(SKAction.sequence([SKAction.wait(forDuration: enemyNumber), SKAction.run { self.initEnemy()}])), withKey: "generator1")
    heart1 = SKSpriteNode(imageNamed: "heart")
    heart1.position = CGPoint(x: heart1.size.width/2 , y: screenSize.height - heart1.size.height/2)
    heart1.zPosition = 70
    addChild(heart1)
    heart2 = SKSpriteNode(imageNamed: "heart")
    heart2.position = CGPoint(x: heart1.position.x + heart2.size.width, y: screenSize.height - heart2.size.height/2)
    heart2.zPosition = 70
    addChild(heart2)
    heart3 = SKSpriteNode(imageNamed: "heart")
    heart3.position = CGPoint(x: heart2.position.x + heart3.size.width , y: screenSize.height - heart1.size.height/2)
    heart3.zPosition = 70
    addChild(heart3)
    
    
  }
    
  // MARK: - Background Functions
  func initBackground() {
    // 1
    background = SKNode()
    addChild(background)
    
    // 2
    for i in 0...2 {
        let tile = SKSpriteNode(imageNamed: "background")
        tile.anchorPoint = CGPoint.zero
        tile.position = CGPoint(x: 0.0 , y: CGFloat(i) * screenSize.height)
        tile.name = "background"
        tile.zPosition = 10
        background.addChild(tile)
    }

  }
   
    
    
  func moveBackground() {
    // 3
    let posY = -background_speed * delta
    background.position = CGPoint(x: 0.0 , y: background.position.y + CGFloat(posY))
    
    // 4
    background.enumerateChildNodes(withName: "background") { (node, stop) in
        let background_screen_position = self.background.convert(node.position, to: self)
        
        if background_screen_position.y <= -node.frame.size.height {
            node.position = CGPoint(x: node.position.x , y: node.position.y + (node.frame.size.height * 2))
        }
        
    }

  }
    func initBoss() {
        boss =  SKSpriteNode(imageNamed: "boss")
        boss.name = "boss"
        boss.position.x = CGFloat(screenSize.width/2)
        boss.position.y = CGFloat(screenSize.height/2 + boss.size.height/2)
        boss.physicsBody = SKPhysicsBody(circleOfRadius: boss.size.height/2)
        boss.physicsBody?.categoryBitMask = FSBossCategory;
        boss.physicsBody?.contactTestBitMask = FSBoundaryCategory | FSPlayerCategory;
        boss.physicsBody?.collisionBitMask = FSBoundaryCategory | FSGapCategory | FSPlayerCategory;
        boss.physicsBody?.mass = 100

        boss.physicsBody?.allowsRotation = false
        
        bossHealth = currentLevel*50
        
        boss.zPosition = 30
        addChild(boss)
        
        label_bossHealth = SKLabelNode(fontNamed:"Copperplate")
        label_bossHealth.fontSize = 20
        label_bossHealth.position.x = screenSize.width - 50
        label_bossHealth.position.y = screenSize.height - 40
        label_bossHealth.text = "Boss: \(bossHealth)"
        label_bossHealth.zPosition = 50
        

        addChild(label_bossHealth)
    }
    func getEnemy() -> SKSpriteNode {
        let enemy =  SKSpriteNode(imageNamed: "enemy")
        enemy.name = "enemy"
//        var value = cos(CGFloat(num/M_PI))
//            if value <= 0{
//                value = 0 - value
//            }
//        enemy.position.x = CGFloat((screenSize.width - enemy.size.width)*value + enemy.size.width/2)
//        num++
        enemy.position.x = CGFloat(arc4random_uniform(UInt32(screenSize.width - enemy.size.width)))
        enemy.position.y = CGFloat(UInt32(screenSize.height)) - enemy.size.height/2
        enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.size)
        enemy.physicsBody?.categoryBitMask = FSPipeCategory;
        enemy.physicsBody?.contactTestBitMask = FSPlayerCategory;
        enemy.physicsBody?.collisionBitMask = FSPlayerCategory;
        enemy.physicsBody?.mass = 0.225
        enemy.physicsBody?.velocity.dy = CGFloat(-100.0)
        enemy.physicsBody?.allowsRotation = false
        
        
        
        enemy.zPosition = 30
        return enemy
    }
    func startMoving(_ velocityMultiplier: CGFloat) {
        
    }
    
    
    
    
    
    func getMissile() ->SKSpriteNode{
        let missile = SKSpriteNode(imageNamed: "missile")
        missile.name = "missile"
        missile.position.x = spaceship.position.x
        missile.position.y = spaceship.position.y
        missile.physicsBody = SKPhysicsBody( rectangleOf: missile.size)
        missile.physicsBody?.categoryBitMask = FSGapCategory
        missile.physicsBody?.contactTestBitMask = FSPipeCategory | FSBossCategory
        missile.physicsBody?.collisionBitMask = FSPipeCategory | FSBossCategory
        missile.physicsBody?.mass = 1.0
        missile.physicsBody?.velocity.dy = CGFloat(300.0)
        missile.physicsBody?.allowsRotation = false
        missile.zPosition = 30
        return missile
    }
    
    func initMissile(){
        let missile = getMissile()
        addChild(missile)
    }
  // MARK: - Pipes Functions
  func initEnemy() {
    
    
//       if(difficulty == "easy"){
//          for count in 0..<3{
//              let count = getEnemy()
//              addChild(count)
//          }
//        
//        }
//        else if(difficulty == "medium"){
//           for count in 0..<6{
//            let count = getEnemy()
//            addChild(count)
//           }
//        
//        }else if(difficulty == "hard"){
//            for count in 0..<8{
//                let count = getEnemy()
//                addChild(count)
//            }
//        
//        }
    addChild(getEnemy())
    
    }


    
  // MARK: - Game Over helpers
  func gameOver() {
    state = .fsGameStateEnded
    bossTime = 0
        if(score > highscore){
            highscore = score
            UserDefaults.standard.set(score, forKey: "highscore")
            UserDefaults.standard.synchronize()

        }else{
            UserDefaults.standard.set(highscore, forKey: "highscore")
            UserDefaults.standard.synchronize()
        }
    
    // 2
    backGroundMusic.pause()
    hits  = 0
    spaceship.physicsBody?.categoryBitMask = 0
    spaceship.physicsBody?.collisionBitMask = FSBoundaryCategory
    removeAction(forKey: "generator")
    removeAction(forKey: "generator1")
    spaceship.removeAllChildren()
    spaceship.removeFromParent()
    removeAllChildren()
    initBackground()
    restart = SKSpriteNode(imageNamed: "Restart")
    restart.position = CGPoint(x: frame.midX, y: frame.midY)
    restart.zPosition = 70
    initHighscore()
    share = SKSpriteNode(imageNamed: "Share")
    share.position = CGPoint(x: frame.midX, y: frame.midY - restart.size.height*1.5)
    share.zPosition = 70
    addChild(share)
    addChild(restart)
    
    // 3
    label_score.position = CGPoint(x: frame.midX, y: frame.maxY - 100)
    addChild(label_score)
    
  }
    
  func restartGame() {
    state = .fsGameStateStarting
    initWorld()
    initBackground()
    initHUD()
    score = 0
    label_score.text = "Score: 0"
    background.addChild(SKSpriteNode(imageNamed: "background"))
  }
    func initHUD() {
        
        // 1
        label_score = SKLabelNode(fontNamed:"Copperplate")
        label_score.fontSize = 20
        label_score.position.x = screenSize.width - 50
        label_score.position.y = screenSize.height - 20
        label_score.text = "Score: \(score)"
        label_score.zPosition = 50
        addChild(label_score)
        
        // 2
        
        //easy game
        easy = SKSpriteNode(imageNamed: "Easy")
        easy.position = CGPoint(x: frame.midX, y: frame.midY  + easy.size.height + 10)
        easy.zPosition = 70
        addChild(easy)
        
        //medium game
        medium = SKSpriteNode(imageNamed: "Medium")
        medium.position = CGPoint(x: frame.midX, y: frame.midY  + medium.size.height - 40)
        medium.zPosition = 70
        addChild(medium)
        
        
        //hard gamef
        hard = SKSpriteNode(imageNamed: "Hard")
        hard.position = CGPoint(x: frame.midX, y: frame.midY  + hard.size.height - 90)
        hard.zPosition = 70
        addChild(hard)
    
        options = SKSpriteNode(imageNamed: "Options")
        options.position = CGPoint(x: frame.midX, y: frame.midY - 100 )
        options.zPosition = 70
        addChild(options)
        
        soundON = SKSpriteNode(imageNamed: "soundON")
        soundON.position = CGPoint(x: frame.midX, y: frame.midY + soundON.size.height)
        soundON.zPosition = 70
        soundON.isHidden = true
        soundON.removeFromParent()
        
        soundOFF = SKSpriteNode(imageNamed: "soundOFF")
        soundOFF.position = CGPoint(x: frame.midX, y: frame.midY - soundOFF.size.height)
        soundOFF.zPosition = 70
        soundOFF.isHidden = true
        soundOFF.removeFromParent()
        
        close = SKSpriteNode(imageNamed: "close")
        close.position = CGPoint(x: close.size.width, y: size.height - close.size.height)
        close.zPosition = 70
        close.isHidden = true
        close.removeFromParent()
        
        pause = SKSpriteNode(imageNamed: "pause")
        pause.position = CGPoint(x: screenSize.width - pause.size.width, y: label_score.position.y - pause.size.height)
        pause.zPosition = 70
        pause.isHidden = true
        pause.removeFromParent()
        
        resume = SKSpriteNode(imageNamed: "resume")
        resume.position = CGPoint(x: frame.midX, y: frame.midY)
        resume.zPosition = 70
        resume.isHidden = true
        resume.removeFromParent()
        
    }
    
    func initHighscore(){
        label_highscore = SKLabelNode(fontNamed:"Copperplate")
        label_highscore.fontSize = 20
        label_highscore.position.x = screenSize.width/2
        label_highscore.position.y = screenSize.height - 30
        label_highscore.text = "Highscore: \(highscore)"
        label_highscore.zPosition = 50
        addChild(label_highscore)
    }
    
    
    
    
    func resumeGame(){
        self.scene?.isPaused = false
    }
    func pauseGame(){
        self.scene?.isPaused = true
    }
//    
//    func showTweetSheet() {
//        let tweetSheet = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
//        tweetSheet.completionHandler = {
//            result in
//            switch result {
//            case SLComposeViewControllerResult.Cancelled:
//                //Add code to deal with it being cancelled
//                break
//                
//            case SLComposeViewControllerResult.Done:
//                //Add code here to deal with it being completed
//                //Remember that dimissing the view is done for you, and sending the tweet to social media is automatic too. You could use this to give in game rewards?
//                break
//            }
//        }
//        
//        tweetSheet.setInitialText("Test Twitter") //The default text in the tweet
//        tweetSheet.addImage(UIImage(named: "TestImage.png")) //Add an image if you like?
//        tweetSheet.addURL(NSURL(string: "http://twitter.com")) //A url which takes you into safari if tapped on
//        var vc = self.view?.window?.rootViewController
//        
//        vc?.presentViewController(tweetSheet, animated: false, completion: nil)
//    }
    
    func shareTextImageAndURL(sharingText: String?, _ sharingImage: UIImage?, sharingURL: URL?) {
        var sharingItems = [AnyObject]()
        
        if let text = sharingText {
            sharingItems.append(text as AnyObject)
        }
        if let image = sharingImage {
            sharingItems.append(image)
        }
        if let url = sharingURL {
            sharingItems.append(url as AnyObject)
        }
        let vc = self.view?.window?.rootViewController
        let activityViewController = UIActivityViewController(activityItems: sharingItems, applicationActivities: nil)
        activityViewController.excludedActivityTypes = [
            UIActivityType.postToWeibo,
            UIActivityType.print,
            UIActivityType.assignToContact,
            UIActivityType.saveToCameraRoll,
            UIActivityType.addToReadingList,
            UIActivityType.postToFlickr,
            UIActivityType.postToVimeo,
            UIActivityType.postToTencentWeibo,
            UIActivityType.copyToPasteboard
        ]
        activityViewController.isModalInPopover = true
        vc?.present(activityViewController, animated: true, completion: nil)
    }
    
  // MARK: - SKPhysicsContactDelegate
  func didBegin(_ contact: SKPhysicsContact) {
    let firstBody = contact.bodyA
    let secondBody = contact.bodyB
    let collision:UInt32 = (firstBody.categoryBitMask | secondBody.categoryBitMask)
    
    // collision between enemy and missile
    if collision == (FSPipeCategory | FSGapCategory) {
        score += 1
        label_score.text = "Score: \(score)"
        
        if score > currentLevel*75 && bossTime != 1{
            bossTime = 1
            removeAction(forKey: "generator1")
            initBoss()
            self.enumerateChildNodes(withName: "enemy") {
                node, stop in
                node.removeFromParent();
            }

        }
        
        firstBody.node?.removeFromParent()
        secondBody.node?.removeFromParent()
        effectsPlayer = try! AVAudioPlayer(contentsOf:laser)
        effectsPlayer.prepareToPlay()
        if volume{
        effectsPlayer.play()
        }
    }
    
    // collision between boss and edge
    if collision == (FSBossCategory | FSBoundaryCategory) {
        if firstBody.node?.name == "spaceship"{
            firstBody.applyImpulse(CGVector(dx: ((firstBody.velocity.dx) * CGFloat(-2.0)), dy: 0)) }
        if secondBody.node?.name == "spaceship"{
            secondBody.applyImpulse(CGVector(dx: ((secondBody.velocity.dx) * CGFloat(-2.0)), dy: 0))}
       
    }
    
    // collision between boss and missile
    if collision == (FSBossCategory | FSGapCategory) {
        if firstBody.node?.name == "missile"
        {
            firstBody.node?.removeFromParent()
        }
        if secondBody.node?.name == "missile"
        {
            secondBody.node?.removeFromParent()
        }
        bossHealth -= 1
        if bossHealth > 0{

            label_bossHealth.text = "Boss: \(bossHealth)"
        } else {
            label_bossHealth.removeFromParent()
            currentLevel += 1
            bossTime = 0
            if firstBody.node?.name == "boss"{
                firstBody.node?.removeFromParent()}
            if secondBody.node?.name == "boss"{
                secondBody.node?.removeFromParent()}
            run(SKAction.repeatForever(SKAction.sequence([SKAction.wait(forDuration: enemyNumber), SKAction.run { self.initEnemy()}])), withKey: "generator1")
        }
    }
    
    // collision between player and enemy
    if collision == (FSPlayerCategory | FSBossCategory) && !dead{
        hits = hits + 1
        dead = true
        effectsPlayer = try! AVAudioPlayer(contentsOf:ow)
        effectsPlayer.prepareToPlay()
        let delayTime1 = DispatchTime.now() + Double(Int64(3.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        run(SKAction.repeatForever(SKAction.sequence([SKAction.wait(forDuration: 0.4), SKAction.run { self.spaceship.run(self.blink)}])), withKey: "blink")
        DispatchQueue.main.asyncAfter(deadline: delayTime1 , execute: {self.revive()})
        if volume{
            effectsPlayer.play()
        }
        if hits <= 3{
            if hits == 1{
                heart3.removeFromParent()
                if firstBody.node?.name == "spaceship"{
                    firstBody.node?.removeFromParent()}
                if secondBody.node?.name == "spaceship"{
                    secondBody.node?.removeFromParent()}
                spaceship.position = CGPoint(x: screenSize.width/2 , y: 0.0)
                let delayTime = DispatchTime.now() + Double(Int64(0.35 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                DispatchQueue.main.asyncAfter(deadline: delayTime , execute: {self.addChild(self.spaceship)})
                
            }
            if hits == 2{
                heart2.removeFromParent()
                if firstBody.node?.name == "spaceship"{
                    firstBody.node?.removeFromParent()}
                if secondBody.node?.name == "spaceship"{
                    secondBody.node?.removeFromParent()}
                spaceship.position = CGPoint(x: screenSize.width/2 , y: 0.0)
                let delayTime = DispatchTime.now() + Double(Int64(0.35 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                DispatchQueue.main.asyncAfter(deadline: delayTime , execute: {self.addChild(self.spaceship)})
            }
            if hits == 3{
                heart3.removeFromParent()
                gameOver()
            }
        }
        
    }
    if collision == (FSPlayerCategory | FSPipeCategory) && !dead{
        hits = hits + 1
        dead = true
        effectsPlayer = try! AVAudioPlayer(contentsOf:ow)
        effectsPlayer.prepareToPlay()
        let delayTime1 = DispatchTime.now() + Double(Int64(3.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        run(SKAction.repeatForever(SKAction.sequence([SKAction.wait(forDuration: 0.4), SKAction.run { self.spaceship.run(self.blink)}])), withKey: "blink")
        DispatchQueue.main.asyncAfter(deadline: delayTime1 , execute: {self.revive()})
        if volume{
            effectsPlayer.play()
        }
        
        if hits <= 3{
            if hits == 1{
                heart3.removeFromParent()
                firstBody.node?.removeFromParent()
                secondBody.node?.removeFromParent()
                spaceship.position = CGPoint(x: screenSize.width/2 , y: 0.0)
                let delayTime = DispatchTime.now() + Double(Int64(0.35 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                DispatchQueue.main.asyncAfter(deadline: delayTime , execute: {self.addChild(self.spaceship)})

            }
            if hits == 2{
                heart2.removeFromParent()
                firstBody.node?.removeFromParent()
                secondBody.node?.removeFromParent()
                spaceship.position = CGPoint(x: screenSize.width/2 , y: 0.0)
                let delayTime = DispatchTime.now() + Double(Int64(0.35 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                DispatchQueue.main.asyncAfter(deadline: delayTime , execute: {self.addChild(self.spaceship)})
            }
            if hits == 3{
                heart3.removeFromParent()
                gameOver()
            }
        }
        
    }

    if collision == (FSPipeCategory | FSBoundaryCategory)
    {
        firstBody.node?.removeFromParent()
        
    }
    
}
    func revive(){
        dead = false
        removeAction(forKey: "blink")
    }
    // Be sure to clear lastTouch when touches end so that the impulses stop being applies
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTouch = nil
    }
    
  // MARK: - Touch Events
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    let touch = touches.first! as UITouch
    let touchLocation = touch.location(in: self)
    
    
    //difficulty easy
    if state == FSGameState.fsGameStateStarting && easy.contains(touchLocation){
        state = .fsGameStatePlaying
        backGroundMusic.play()
        missileNumber = 0.2
        enemyNumber = 0.6
        
        
       
    lastTouch = touchLocation
        pause.isHidden = false
        addChild(pause)
        easy.isHidden = true
        medium.isHidden = true
        hard.isHidden = true
        options.isHidden = true
        initSpaceship()
    }
        //difficulty medium
    if state == FSGameState.fsGameStateStarting && medium.contains(touchLocation){
        state = .fsGameStatePlaying
        backGroundMusic.play()
        missileNumber = 0.2
        enemyNumber = 0.3
        
        lastTouch = touchLocation
        pause.isHidden = false
        addChild(pause)
        easy.isHidden = true
        medium.isHidden = true
        hard.isHidden = true
        options.isHidden = true
        initSpaceship()
    }
    //difficulty hard
    if state == FSGameState.fsGameStateStarting && hard.contains(touchLocation){
        state = .fsGameStatePlaying
        backGroundMusic.play()
        missileNumber = 0.2
        enemyNumber = 0.15
        
        lastTouch = touchLocation
        pause.isHidden = false
        addChild(pause)
        easy.isHidden = true
        medium.isHidden = true
        hard.isHidden = true
        options.isHidden = true
        initSpaceship()
    }
    
    
    
    
    
    
    
    
    if state == FSGameState.fsGameStatePlaying && pause.contains(touchLocation){
        state = .fsGameStatePaused
        backGroundMusic.pause()
        pauseGame()
        pause.removeFromParent()
        pause.isHidden = true
        resume.isHidden = false
        addChild(resume)
        if backGroundMusic.volume == 1.0{
            soundON.isHidden = false
            addChild(soundON)
        }
        if backGroundMusic.volume == 0.0{
            soundOFF.isHidden = false
            addChild(soundOFF)
        }
        
    }
    
    if state == FSGameState.fsGameStatePaused && resume.contains(touchLocation){
        resumeGame()
        backGroundMusic.play()
        resume.isHidden = true
        soundOFF.isHidden = true
        soundOFF.removeFromParent()
        soundON.isHidden = true
        soundON.removeFromParent()
        resume.removeFromParent()
        pause.isHidden = false
        addChild(pause)
        state = .fsGameStatePlaying
        
    }
    if state == FSGameState.fsGameStateStarting && options.contains(touchLocation){
        easy.removeFromParent()
        medium.removeFromParent()
        hard.removeFromParent()
        options.removeFromParent()
        close.isHidden = false
        addChild(close)
        state = .fsGameStateSetting
        if backGroundMusic.volume == 1.0{
            soundON.isHidden = false
            addChild(soundON)
        }
        if backGroundMusic.volume == 0.0{
            soundOFF.isHidden = false
            addChild(soundOFF)
        }
    }
    if state == FSGameState.fsGameStateSetting && close.contains(touchLocation){
        state = .fsGameStateStarting
        close.removeFromParent()
        close.isHidden = true
        soundOFF.isHidden = true
        soundOFF.removeFromParent()
        soundON.isHidden = true
        soundON.removeFromParent()
        addChild(easy)
        addChild(medium)
        addChild(hard)
        addChild(options)
    }
    if (state == FSGameState.fsGameStateSetting || state == FSGameState.fsGameStatePaused) && soundOFF.contains(touchLocation){
        soundOFF.isHidden = true
        soundOFF.removeFromParent()
        backGroundMusic.volume = 1.0
        effectsPlayer.volume = 1.0
        volume = true
        soundON.isHidden = false
        addChild(soundON)
    }
    
    if (state == FSGameState.fsGameStateSetting || state == FSGameState.fsGameStatePaused) && soundON.contains(touchLocation){
        soundON.isHidden = true
        soundON.removeFromParent()
        backGroundMusic.volume = 0.0
        effectsPlayer.volume = 0.0
        volume = false
        soundOFF.isHidden = false
        addChild(soundOFF)
    }
    if state == FSGameState.fsGameStateEnded && share.contains(touchLocation){
        UIGraphicsBeginImageContextWithOptions(self.view!.bounds.size, false, UIScreen.main.scale)
        self.view!.drawHierarchy(in: self.view!.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        shareTextImageAndURL(sharingText: "I just scored \(score) on Galaxy Fighters", image, sharingURL: nil)
    }
    if state == FSGameState.fsGameStateEnded && restart.contains(touchLocation)
    {
        label_highscore.text = ""
        label_score.removeFromParent()
        restart.removeFromParent()
        share.removeFromParent()
        self.restartGame()
    }
  }
    
    func runGame(){
        initMissile()
        initEnemy()

    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first! as UITouch
        let touchLocation = touch.location(in: self)
        lastTouch = touchLocation
    }
    func disappear(){
        spaceship.isHidden = true
    }
    func appear(){
        spaceship.isHidden = false
    }
  // MARK: - Frames Per Second
  override func update(_ currentTime: TimeInterval) {
    // 6

        var delayTime1 = DispatchTime.now() + Double(Int64(0.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
    
//    if dead{
//        //var x = 0.0
//    for x in 0..<3 {
//        delayTime1 = dispatch_time(DISPATCH_TIME_NOW,Int64(Double(x) * Double(NSEC_PER_SEC)))
//        dispatch_after(delayTime1 , dispatch_get_main_queue(), {self.disappear()})
//        delayTime1 = dispatch_time(DISPATCH_TIME_NOW,Int64((Double(x)+0.5) * Double(NSEC_PER_SEC)))
//       dispatch_after(delayTime1 , dispatch_get_main_queue(), {self.appear()})
//    }
//    }
    let max_speed = CGFloat(0.5)
    if state == .fsGameStatePlaying{
    if spaceship.physicsBody?.velocity.dx > max_speed{
        spaceship.physicsBody?.velocity.dx = max_speed
    }
    if spaceship.physicsBody?.velocity.dy > max_speed{
        spaceship.physicsBody?.velocity.dy = max_speed
    }
        if let potato = boss{
        if boss?.position.x != spaceship?.position.x && boss?.position.y != spaceship?.position.y{
            let impulseVector = CGVector(dx:  (spaceship.position.x - boss.position.x)*2 , dy:  (spaceship.position.y - boss.position.y)*2 )
            boss?.physicsBody?.applyImpulse(impulseVector)
        }
        }
//    if spaceship.position.x == lastTouch?.x && spaceship.position.y == lastTouch?.y{
//        spaceship.physicsBody?.velocity = CGVector(dx: 0.0, dy: 0.0)
//    }
    spaceship.physicsBody?.linearDamping = 1.0
    spaceship.physicsBody?.angularDamping = 1.0
    delta = (last_update_time == 0.0) ? 0.0 : currentTime - last_update_time
    last_update_time = currentTime
    if let touch = lastTouch {
        let impulseVector = CGVector(dx: touch.x - spaceship.position.x, dy: touch.y - spaceship.position.y)
        // If myShip starts moving too fast or too slow, you can multiply impulseVector by a constant or clamp its range
        spaceship.physicsBody?.applyImpulse(impulseVector)
    }else if !(spaceship.physicsBody?.isResting != nil) {
        // Adjust the -0.5 constant accordingly
        let impulseVector = CGVector(dx: (spaceship.physicsBody?.velocity.dx)! * -0.5, dy: (spaceship.physicsBody?.velocity.dy)! * -0.5)
        spaceship.physicsBody?.applyImpulse(impulseVector)
    }
    // 7
    moveBackground()
  }else {
        //
    }
    }
}
