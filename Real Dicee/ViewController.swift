//
//  ViewController.swift
//  Real Dicee
//
//  Created by Nishant Taneja on 11/09/20.
//  Copyright © 2020 Nishant Taneja. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    //MARK:- IBOutlet
    @IBOutlet var sceneView: ARSCNView!
    
    //MARK:- Override View Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // SceneView Delegate|Options
        sceneView.delegate = self
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        sceneView.autoenablesDefaultLighting = true
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        // Run the view's session
        sceneView.session.run(configuration)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Pause the view's session
        sceneView.session.pause()
    }
    
    //MARK:- Touch Detection Methods
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: sceneView)
            if let hitResult = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent).first {
                // Create diceScene
                guard let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn") else {fatalError("error loading diceCollada.scn")}
                if let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true) {
                    // Adding dice in RealWorld
                    let worldCoordinates = hitResult.worldTransform.columns.3
                    diceNode.position = SCNVector3(worldCoordinates.x, worldCoordinates.y + diceNode.boundingSphere.radius, worldCoordinates.z)
                    sceneView.scene.rootNode.addChildNode(diceNode)
                    // Rolling dice
                    let randomX = CGFloat(arc4random_uniform(4) + 1) * .pi/2
                    let randomZ = CGFloat(arc4random_uniform(4) + 1) * .pi/2
                    diceNode.runAction(SCNAction.rotateBy(x: randomX, y: 0, z: randomZ*5, duration: 0.5))
                }
            }
        }
    }
    
    //MARK:- ARSCNViewDelegate
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // Display Plane in Real World
        guard let planeAnchor = anchor as? ARPlaneAnchor else {return}
        // Create Geometry
        let anchorDimensions = planeAnchor.extent
        let plane = SCNPlane(width: CGFloat(anchorDimensions.x), height: CGFloat(anchorDimensions.z))
        // Add Materials
        let gridMaterial = SCNMaterial()
        gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
        plane.materials = [gridMaterial]
        // Create Node
        let anchorPosition = planeAnchor.center
        let planeNode = SCNNode()
        planeNode.geometry = plane
        planeNode.position = SCNVector3(anchorPosition.x, 0, anchorPosition.z)
        planeNode.transform = SCNMatrix4MakeRotation(-.pi/2, 1, 0, 0)
        node.addChildNode(planeNode)
    }
}
