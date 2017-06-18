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
    
    var viewController: ViewController!
    var animotosDict = [UUID: String]()
    
    var currentLoc: CLLocationCoordinate2D? {
        didSet {
            for a in animotosDict {
                animotosDict.removeValue(forKey: a.key)
                viewController.nodesDict[a.key]?.removeFromParent()
                viewController.nodesDict.removeValue(forKey: a.key)
            }
            print(currentLoc!)
            myLabel.text = String(describing: currentLoc!.convertSphericalToCartesian())
        }
    }
    
    private var myLabel: SKLabelNode!
    
    override func didMove(to view: SKView) {
        // Setup your scene here
        myLabel = SKLabelNode(fontNamed: "Arial")
        myLabel.text = ""
        myLabel.fontSize = 12
        myLabel.position = CGPoint(x: 0, y: size.height - 250)
        addChild(myLabel)
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
//        if !animotosDict.values.contains("mydesk") {
//            spawnDesk(withLocation: myDeskLocation, name: "mydesk")
//        } else if !animotosDict.values.contains("aivensdesk") {
//            spawnDesk(withLocation: AivensDeskLocation, name: "aivensdesk")
//        }
        
        if !animotosDict.values.contains("coffeetable") {
            spawnDesk(withLocation: coffeeTabelLocation, name: "coffeetable")
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard let sceneView = self.view as? ARSKView else {
//            return
//        }
//
//        if let touchLocation = touches.first?.location(in: sceneView),
//            let node = nodes(at: touchLocation).first {
//            if let anchor = sceneView.anchor(for: node) {
//                animotosDict.removeValue(forKey: anchor.identifier)
//            }
//            node.removeFromParent()
//        }
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
            let xDiff = Float(mydeskx - xx) * 1000
            print("x is \(xDiff)")
            //translation.columns.3.x = xDiff
            
            // Either to the top or bottom of camera
            let yDiff = Float(mydesky - yy) * 1000
            print("y is \(yDiff)")
            translation.columns.3.y = yDiff
            
            // Either behind or in front of camera
            let zDiff = Float(mydeskz - zz) * 1000
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
