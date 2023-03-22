//
//  ViewController.swift
//  Eyes Tracking
//
//  Created by Virakri Jinangkul on 6/6/18.
//  Copyright © 2018 virakri. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import WebKit
import SwiftUI
import ReplayKit
import AVFoundation
import GoogleSignIn
import GoogleSignInSwift


class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var eyePositionIndicatorView: UIView!
    @IBOutlet weak var eyePositionIndicatorCenterView: UIView!
    @IBOutlet weak var blurBarView: UIVisualEffectView!
    @IBOutlet weak var lookAtPositionXLabel: UILabel!
    @IBOutlet weak var lookAtPositionYLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var mySliderLeye: UISlider!
    @IBOutlet weak var mySliderReye: UISlider!
    @IBOutlet weak var mySliderDistance: UISlider!
    var isRecording = false
    let screenRecorder = RPScreenRecorder.shared()
    var url: URL?
    
    

    var loginButton = GIDSignInButton(frame: CGRect(x: 10, y: 10, width: 100, height: 44))
    var faceNode: SCNNode = SCNNode()
    
    
    var eyeLNode: SCNNode = {
        let geometry = SCNCone(topRadius: 0.005, bottomRadius: 0, height: 0.2)
        geometry.radialSegmentCount = 3
        geometry.firstMaterial?.diffuse.contents = UIColor.blue
        let node = SCNNode()
        node.geometry = geometry
        node.eulerAngles.x = -.pi / 2
        node.position.z = 0.1
        let parentNode = SCNNode()
        parentNode.addChildNode(node)
        return parentNode
    }()
    
    var eyeRNode: SCNNode = {
        let geometry = SCNCone(topRadius: 0.005, bottomRadius: 0, height: 0.2)
        geometry.radialSegmentCount = 3
        geometry.firstMaterial?.diffuse.contents = UIColor.blue
        let node = SCNNode()
        node.geometry = geometry
        node.eulerAngles.x = -.pi / 2
        node.position.z = 0.1
        let parentNode = SCNNode()
        parentNode.addChildNode(node)
        return parentNode
    }()
    
    var lookAtTargetEyeLNode: SCNNode = SCNNode()
    var lookAtTargetEyeRNode: SCNNode = SCNNode()
    

    
    let phoneScreenSize = CGSize(width: 0.1573389284, height: 0.2269145561)
    let phoneScreenPointSize = CGSize(width: 820, height: 1180)
    
    var virtualPhoneNode: SCNNode = SCNNode()
    
    var virtualScreenNode: SCNNode = {
        
        let screenGeometry = SCNPlane(width: 1, height: 1)
        screenGeometry.firstMaterial?.isDoubleSided = true
        screenGeometry.firstMaterial?.diffuse.contents = UIColor.green
        
        return SCNNode(geometry: screenGeometry)
    }()
    
    var eyeLookAtPositionXs: [CGFloat] = []
    var eyeLookAtPositionYs: [CGFloat] = []
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Setup Design Elements
        eyePositionIndicatorView.layer.cornerRadius = eyePositionIndicatorView.bounds.width / 2
        sceneView.layer.cornerRadius = 28
        eyePositionIndicatorCenterView.layer.cornerRadius = 4
        
        blurBarView.layer.cornerRadius = 36
        blurBarView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.session.delegate = self
        sceneView.automaticallyUpdatesLighting = true
        
        // Setup Scenegraph
        sceneView.scene.rootNode.addChildNode(faceNode)
        sceneView.scene.rootNode.addChildNode(virtualPhoneNode)
        virtualPhoneNode.addChildNode(virtualScreenNode)
        faceNode.addChildNode(eyeLNode)
        faceNode.addChildNode(eyeRNode)
        eyeLNode.addChildNode(lookAtTargetEyeLNode)
        eyeRNode.addChildNode(lookAtTargetEyeRNode)
        
        // Set LookAtTargetEye at 2 meters away from the center of eyeballs to create segment vector
        lookAtTargetEyeLNode.position.z = 2
        lookAtTargetEyeRNode.position.z = 2
 
        mySliderLeye.addTarget(self, action: #selector(mySliderLeyeValueChanged(_:)), for: .valueChanged)
        mySliderReye.addTarget(self, action: #selector(mySliderReyeValueChanged(_:)), for: .valueChanged)
    }
    @objc func mySliderLeyeValueChanged(_ sender: UISlider) {
        lookAtTargetEyeLNode.position.z = sender.value
        print("Slider value changed to \(sender.value)")
    }
    @objc func mySliderReyeValueChanged(_ sender: UISlider) {
        lookAtTargetEyeRNode.position.z = sender.value
    }
    
            
        
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            
            // Create a session configuration
            guard ARFaceTrackingConfiguration.isSupported else { return }
            let configuration = ARFaceTrackingConfiguration()
            configuration.isLightEstimationEnabled = true
            
            // Run the view's session
            sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        }
        
        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            
            // Pause the view's session
            sceneView.session.pause()
        }
        
        // MARK: - ARSCNViewDelegate
        
        func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
            
            faceNode.transform = node.transform
            guard let faceAnchor = anchor as? ARFaceAnchor else { return }
            
            update(withFaceAnchor: faceAnchor)
        }
    
        func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
            guard let faceAnchor = anchor as? ARFaceAnchor, let device = renderer.device else { return nil}
            let faceGeometry = ARSCNFaceGeometry(device: device)
            let node = SCNNode(geometry: faceGeometry)
            node.geometry?.firstMaterial?.fillMode = .lines
            return node
            
        }
        
        // MARK: - update(ARFaceAnchor)
        
        func update(withFaceAnchor anchor: ARFaceAnchor) {
            
            eyeRNode.simdTransform = anchor.rightEyeTransform
            eyeLNode.simdTransform = anchor.leftEyeTransform
            
            var eyeLLookAt = CGPoint()
            var eyeRLookAt = CGPoint()
            
            let heightCompensation: CGFloat = 350
            //height from camera to center of screen
            
            DispatchQueue.main.async {
                
                // Perform Hit test using the ray segments that are drawn by the center of the eyeballs to somewhere two meters away at direction of where users look at to the virtual plane that place at the same orientation of the phone screen
                
                let phoneScreenEyeRHitTestResults = self.virtualPhoneNode.hitTestWithSegment(from: self.lookAtTargetEyeRNode.worldPosition, to: self.eyeRNode.worldPosition, options: nil)
                
                let phoneScreenEyeLHitTestResults = self.virtualPhoneNode.hitTestWithSegment(from: self.lookAtTargetEyeLNode.worldPosition, to: self.eyeLNode.worldPosition, options: nil)
                
                for result in phoneScreenEyeRHitTestResults {
                    
                    eyeRLookAt.x = CGFloat(result.localCoordinates.x) / (self.phoneScreenSize.width / 2) * self.phoneScreenPointSize.width
                    
                    eyeRLookAt.y = CGFloat(result.localCoordinates.y) / (self.phoneScreenSize.height / 2) * self.phoneScreenPointSize.height + heightCompensation
                }
                
                for result in phoneScreenEyeLHitTestResults {
                    
                    eyeLLookAt.x = CGFloat(result.localCoordinates.x) / (self.phoneScreenSize.width / 2) * self.phoneScreenPointSize.width
                    
                    eyeLLookAt.y = CGFloat(result.localCoordinates.y) / (self.phoneScreenSize.height / 2) * self.phoneScreenPointSize.height + heightCompensation
                }
                
                // Add the latest position and keep up to 8 recent position to smooth with.
                let smoothThresholdNumber: Int = 5
                //speed or slow down
                self.eyeLookAtPositionXs.append((eyeRLookAt.x + eyeLLookAt.x) / 2)
                self.eyeLookAtPositionYs.append(-(eyeRLookAt.y + eyeLLookAt.y) / 2)
                self.eyeLookAtPositionXs = Array(self.eyeLookAtPositionXs.suffix(smoothThresholdNumber))
                self.eyeLookAtPositionYs = Array(self.eyeLookAtPositionYs.suffix(smoothThresholdNumber))
                
                let smoothEyeLookAtPositionX = self.eyeLookAtPositionXs.average!
                let smoothEyeLookAtPositionY = self.eyeLookAtPositionYs.average!
                
                // update indicator position
                self.eyePositionIndicatorView.transform = CGAffineTransform(translationX: smoothEyeLookAtPositionX, y: smoothEyeLookAtPositionY)
                
                // update eye look at labels values
                self.lookAtPositionXLabel.text = "\(Int(round(smoothEyeLookAtPositionX + self.phoneScreenPointSize.width / 2)))"
                
                self.lookAtPositionYLabel.text = "\(Int(round(smoothEyeLookAtPositionY + self.phoneScreenPointSize.height / 2)))"
                
                // Calculate distance of the eyes to the camera
                let distanceL = self.eyeLNode.worldPosition - SCNVector3Zero
                let distanceR = self.eyeRNode.worldPosition - SCNVector3Zero
                
                // Average distance from two eyes
                let distance = (distanceL.length() + distanceR.length()) / 2
                
                // Update distance label value
                self.distanceLabel.text = "\(Int(round(distance * 100))) cm"
                
            }
            
        }
        
        func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
            virtualPhoneNode.transform = (sceneView.pointOfView?.transform)!
        }
        
        func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
            faceNode.transform = node.transform
            guard let faceAnchor = anchor as? ARFaceAnchor else { return }
            update(withFaceAnchor: faceAnchor)
        }
    }


