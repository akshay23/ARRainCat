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
    
    private var lastUpdateTime : TimeInterval = 0
    private var currentAnimotoSpawnRate : TimeInterval = 0
    private var animotoSpawnRate : TimeInterval = 2.0
    private var myLabel: SKLabelNode!
    private var currentLoc: CLLocationCoordinate2D?
    
    override func didMove(to view: SKView) {
        // Setup your scene here
        lastUpdateTime = 0
        
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
        
        if currentAnimotoSpawnRate > animotoSpawnRate {
            currentAnimotoSpawnRate = 0
            animotoSpawnRate = Double(Float.random(lower: 2.0, 3.0))
            //spawnAnimoto()
        }
        
        self.lastUpdateTime = currentTime
        
        // Update label
        if let loc = currentLoc {
            myLabel.text = String(describing: loc.convertSphericalToCartesian())
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let sceneView = self.view as? ARSKView else {
            return
        }
        
        if let touchLocation = touches.first?.location(in: sceneView),
            let node = nodes(at: touchLocation).first {
            node.removeFromParent()
        }
    }
    
    func updateLocation(withLocation loc: CLLocationCoordinate2D) {
        currentLoc = loc
    }
}

private extension Scene {
    func spawnAnimoto() {
        guard let sceneView = self.view as? ARSKView else {
            return
        }
        
        // Create anchor using the camera's current position
        if let currentFrame = sceneView.session.currentFrame {
            
            // Create a transform with a random translation between
            // 0.1 meters and 0.3 meters in front of the camera
            var translation = matrix_identity_float4x4
            //translation.columns.3.w = -(Float.random(lower: 0.1, 0.4)) // distance behind camera
            //translation.columns.3.x = -(Float.random(lower: 0.1, 0.4)) // distance to the right of camera
            //translation.columns.2.y = -(Float.random(lower: 0.1, 0.5))
            //translation.columns.3.z = -(Float.random(lower: 0.1, 0.3)) // distance in front of camera
            translation.columns.3.z = -0.3
            let transform = simd_mul(currentFrame.camera.transform, translation)
            
            // Add a new anchor to the session
            let anchor = ARAnchor(transform: transform)
            sceneView.session.add(anchor: anchor)
        }
    }
}

extension Float {
    static func random(lower: Float = 0, _ upper: Float = 100) -> Float {
        return (Float(arc4random()) / 0xFFFFFFFF) * (upper - lower) + lower
    }
}
