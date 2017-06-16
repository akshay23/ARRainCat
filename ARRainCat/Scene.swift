//
//  Scene.swift
//  ARRainCat
//
//  Created by Akshay Bharath on 6/15/17.
//  Copyright © 2017 Actionman Inc. All rights reserved.
//

import SpriteKit
import ARKit
import CoreLocation

class Scene: SKScene {
    
    var animotosDict = [UUID: String]()
    private var lastUpdateTime : TimeInterval = 0
    private var currentAnimotoSpawnRate : TimeInterval = 0
    private var animotoSpawnRate : TimeInterval = 4.0
    private var myLabel: SKLabelNode!
    private var currentLoc: CLLocationCoordinate2D?
    
    override func didMove(to view: SKView) {
        // Setup your scene here
        myLabel = SKLabelNode(fontNamed: "Arial")
        myLabel.text = ""
        myLabel.fontSize = 15
        myLabel.position = CGPoint(x: 0, y: size.height - 250)
        addChild(myLabel)
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        // Initialize _lastUpdateTime if it has not already been
        if (self.lastUpdateTime == 0) {
            self.lastUpdateTime = currentTime
        }
        
        // Calculate time since last update
        let dt = currentTime - self.lastUpdateTime
        
        // Update the Spawn Timer
        currentAnimotoSpawnRate += dt
        
        if currentAnimotoSpawnRate > animotoSpawnRate, !animotosDict.values.contains("mydesk") {
            currentAnimotoSpawnRate = 0
            animotoSpawnRate = Double(Float.random(lower: 2.0, 3.0))
            spawnDesk(withLocation: myDeskLocation, name: "mydesk")
        } else if currentAnimotoSpawnRate > animotoSpawnRate, !animotosDict.values.contains("aivensdesk") {
            currentAnimotoSpawnRate = 0
            animotoSpawnRate = Double(Float.random(lower: 2.0, 3.0))
            spawnDesk(withLocation: AivensDeskLocation, name: "aivensdesk")
        }
        
        self.lastUpdateTime = currentTime
        
//        if let loc = currentLoc {
//            print(loc.convertSphericalToCartesian())
//            myLabel.text = String(describing: loc.convertSphericalToCartesian())
//        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard let sceneView = self.view as? ARSKView else {
//            return
//        }
//
//        if let touchLocation = touches.first?.location(in: sceneView),
//            let node = nodes(at: touchLocation).first {
//            node.removeFromParent()
//
//            // HACK
//            if let name = node.name, name == "mydesk" {
//                animotosDict = [UUID: String]()
//            }
//        }
    }
    
    func updateLocation(withLocation loc: CLLocationCoordinate2D) {
        currentLoc = loc
    }
}

private extension Scene {
    func spawnDesk(withLocation location: (Double,Double,Double), name: String) {
        guard let sceneView = self.view as? ARSKView else {
            return
        }
        
        // Create anchor using the camera's current position
        if let currentFrame = sceneView.session.currentFrame {
            
            // Create a transform with a translation that
            // represents location of my desk
            var translation = matrix_identity_float4x4
            let (xx , yy, zz) = currentLoc!.convertSphericalToCartesian()
            let (mydeskx, mydesky, mydeskz) = location
            
            // Name
            print("Name is \(name)")
            
            // Either to the right or left of camera
            let xDiff = Float(mydeskx - xx) * 100
            print("x is \(xDiff)")
            translation.columns.3.x = xDiff
            
            // Either to the top or bottom of camera
            let yDiff = Float(mydesky - yy) * 100
            print("y is \(yDiff)")
            translation.columns.3.y = yDiff
            
            // Either behind or in front of camera
            let zDiff = Float(mydeskz - zz) * 100
            print("z is \(zDiff)")
            translation.columns.3.z = zDiff
            
            let transform = simd_mul(currentFrame.camera.transform, translation)
            
            // Add a new anchor to the session
            let anchor = ARAnchor(transform: transform)
            sceneView.session.add(anchor: anchor)
            animotosDict[anchor.identifier] = name
        }
    }
}

extension Float {
    static func random(lower: Float = 0, _ upper: Float = 100) -> Float {
        return (Float(arc4random()) / 0xFFFFFFFF) * (upper - lower) + lower
    }
}
