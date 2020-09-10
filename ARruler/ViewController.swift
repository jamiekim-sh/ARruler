//
//  ViewController.swift
//  ARruler
//
//  Created by Jamie Kim  on 9/7/20.
//  Copyright © 2020 Jamie Kim . All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var dotNodes = [SCNNode]()
    var textNode = SCNNode()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        //add debug options -automatic detected feature points
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if dotNodes.count >= 2 {
            for dot in dotNodes {
                //remove each previous dots in the array off the scene
                dot.removeFromParentNode()
            }
            //initialize to empty array
            dotNodes = [SCNNode]()
        }
        //    print("touch detected")
        //grab touch location
        if let touchLocation = touches.first?.location(in: sceneView){
            //location in 3d space inside of real world in side of scene
            let hitTestResults = sceneView.hitTest(touchLocation, types: .featurePoint)
            
            if let hitResult = hitTestResults.first{
                //add dots
                addDot(at: hitResult)
            }
        }
    }
    

    func addDot(at hitResult : ARHitTestResult){
        //3d sphere in AR kit
        let dotGeometry = SCNSphere(radius: 0.005)
        
        let material = SCNMaterial()
        
        material.diffuse.contents = UIColor.systemPurple
        
        dotGeometry.materials = [material]
        
        let dotNode = SCNNode(geometry: dotGeometry)
        //where positions of dots are; start and end points
        dotNode.position = SCNVector3Make(hitResult.worldTransform.columns.3.x, hitResult.worldTransform.columns.3.y, hitResult.worldTransform.columns.3.z)
        
        sceneView.scene.rootNode.addChildNode(dotNode)
        //append to dotNodes array whenever we create a new position
        dotNodes.append(dotNode)
        
        //start and end points
        if dotNodes.count >= 2{
            calculate()
        }
    }

    func calculate(){
        let start = dotNodes[0]
        let end = dotNodes[1]
        //print(start.position)
        
        //distance = √((x2-x1)^2 + (y2-y1)^2 + (z2-z1)^2)
        let a = end.position.x - start.position.x
        let b = end.position.y - start.position.y
        let c = end.position.z - start.position.z
        
        let distance = sqrt(pow(a,2)+pow(b,2)+pow(c,2))
        
       // print(abs(distance))
        
        updateText(text: "\(abs(distance))", atPosition: end.position)
    }
    
    //now want to able to show text inside of the scene
    //text 3D geometry
    func updateText(text: String, atPosition position: SCNVector3){
        //remove text everysingle time it gets called
        textNode.removeFromParentNode()
        let textGeometry = SCNText(string: text, extrusionDepth: 1.0)
        //let material = SCNMaterial()
        textGeometry.firstMaterial?.diffuse.contents = UIColor.red
        textNode = SCNNode(geometry: textGeometry)
        textNode.position = SCNVector3(position.x, position.y+0.01, position.z)
        //textNode.position = SCNVector3Make(0, 0.01, -0.1)
        //scale down
        textNode.scale = SCNVector3(0.01, 0.01, 0.01)
        //add textNode to scene
        sceneView.scene.rootNode.addChildNode(textNode)
    }
}


