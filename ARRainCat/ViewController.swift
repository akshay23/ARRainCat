//
//  ViewController.swift
//  ARRainCat
//
//  Created by Akshay Bharath on 6/15/17.
//  Copyright © 2017 Actionman Inc. All rights reserved.
//

import UIKit
import SpriteKit
import ARKit
import CoreLocation

class ViewController: UIViewController {
    
    @IBOutlet var sceneView: ARSKView!
    
    var locationManager: CLLocationManager!
    var myScene: Scene!
    var nodesDict = [UUID: SKNode]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and node count
        sceneView.showsNodeCount = true
        
        // Load the SKScene from 'Scene.sks'
        if let scene = SKScene(fileNamed: "Scene") {
            sceneView.presentScene(scene)
            
            if let s = scene as? Scene {
                myScene = s
                myScene.viewController = self
            }
        }
        
        // Location manager
        locationManager = CLLocationManager()
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingSessionConfiguration()
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        myScene.currentLoc = locValue
        //locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}

// MARK: - ARSKViewDelegate
extension ViewController: ARSKViewDelegate {
    func view(_ view: ARSKView, nodeFor anchor: ARAnchor) -> SKNode? {
        // HACK
        if let type = myScene.animotosDict[anchor.identifier] {
            let animotoTexture = SKTexture(imageNamed: "animoto")
            let animoto = SKSpriteNode(texture: animotoTexture)
            animoto.name = type
            nodesDict[anchor.identifier] = animoto
            return animoto;
        }
        return nil
    }
    
    func view(_ view: ARSKView, didRemove node: SKNode, for anchor: ARAnchor) {
        
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}

extension FloatingPoint {
    var degreesToRadians: Self { return self * .pi / 180 }
    var radiansToDegrees: Self { return self * 180 / .pi }
}

extension CLLocationCoordinate2D {
    func convertSphericalToCartesian() -> (Double, Double, Double) {
        let rad = 500.0
        let cosLat = cos(latitude.degreesToRadians)
        let sinLat = sin(latitude.degreesToRadians)
        let cosLon = cos(longitude.degreesToRadians)
        let sinLon = sin(longitude.degreesToRadians)
        return (rad * cosLat * cosLon, rad * cosLat * sinLon, rad * sinLat)
    }
    
//    func convertSphericalToCartesian() -> (Double, Double, Double) {
//        let h = 0.0
//        let f = 1.0 / 298.257224
//        let rad = 6378137.0
//        let cosLat = cos(latitude.degreesToRadians)
//        let sinLat = sin(latitude.degreesToRadians)
//        let cosLon = cos(longitude.degreesToRadians)
//        let sinLon = sin(longitude.degreesToRadians)
//        let C = 1.0 / sqrt(cosLat * cosLat + (1 - f) * (1 - f) * sinLat * sinLat)
//        let S = (1.0 - f) * (1.0 - f) * C
//
//        return ((rad * C + h) * cosLat * cosLon, (rad * C + h) * cosLat * sinLon, (rad * S + h) * sinLat)
//    }
    
//    func convertSphericalToCartesian() -> (Double, Double, Double) {
//        let earthRadius = 6367.0; //radius in km
//        let lt = self.latitude.degreesToRadians
//        let ln = self.longitude.degreesToRadians
//        let x = earthRadius * cos(lt) * cos(ln)
//        let y = earthRadius * cos(lt) * sin(ln)
//        let z = earthRadius * sin(lt)
//        return (x, y, z)
//    }
}
