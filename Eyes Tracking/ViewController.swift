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
import AVFoundation



//Y IS smaller at top and bigger at bottom
//X gets bigger from left to right
//
//can add pupil size tracker
//can add frames per second for eye tracking
//add AVCaptureDevice.Position?
//captureDeviceType
//var providesAudioData: Bool { get set }
//ARConfiguration.SceneReconstruction
//add relocalization?
//add heat map?
//capturedDepthDataTimestamp
//add other post-processing
//add device to data text file?
//add low pass filter?
//add session ID? (put all saved files from a session into one folder)
//add orientation to the ET data

//TIMESTAMPS:
//CACurrentMedia = CFTimeInterval derived by calling mach_absolute_time() and converting the result to seconds.

//add eyelid detection and pupil image detection for calibration w bears?
//add orientation to eye track data?


//add stack view

struct EyeTrackingData: Codable {
    let position: CGPoint
    var timestamp: TimeInterval
    var eyelidValue: Float
}

public struct FixationData {
    let center: CGPoint
    let duration: TimeInterval
    let startTime: TimeInterval // Timestamp when the fixation starts
}

//typealias VNConfidence = Float


class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate, WKNavigationDelegate {
    
    //@IBOutlet weak var webView: WKWebView!
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var eyePositionIndicatorView: UIView!
    @IBOutlet weak var eyePositionIndicatorCenterView: UIView!
    @IBOutlet weak var blurBarView: UIVisualEffectView!
    @IBOutlet weak var lookAtPositionXLabel: UILabel!
    @IBOutlet weak var lookAtPositionYLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    @IBOutlet weak var deviceButton: UIButton!
    @IBOutlet var webView: WKWebView!
    //var webView: WKWebView!
    
    var isRecording: Bool = false
    @IBOutlet weak var recordButton: UIImageView!
    @State var url: URL?
    
    var fixations: [FixationData] = [] // Define the fixations property
    
    var videoURL: URL? // Define the videoURL property
    
    var startRecordingEye: (()->())? //contentview can accept optional parameter
    var stopRecordingEye: (()->())?
    
    // initialize eye tracking data
    var eyeTrackingData: [EyeTrackingData] = []
    var eyeTrackingStartTimestamp: TimeInterval = 0
    var screenRecordingStartTime: Date?
    var eyeTrackingStartTime: Date?
    
    //set device measures:
    var device: Device = .iPadPro11
    
    
    //bears
    @IBOutlet var upperLeftCorner: UIView!
    @IBOutlet var upperRightCorner: UIView!
    @IBOutlet var lowerLeftCorner: UIView!
    @IBOutlet var lowerRightCorner: UIView!
    
    //button horizontal stack view
    @IBOutlet weak var stackView: UIStackView!
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        let dotViews = [upperLeftCorner, upperRightCorner, lowerRightCorner, lowerLeftCorner]
            
            // Toggle visibility of dotViews
        let isHidden = !dotViews[0]!.isHidden
            for dotView in dotViews {
                dotView?.isHidden = isHidden
                if !isHidden {
                    view.bringSubviewToFront(dotView!)
                } else {
                    view.sendSubviewToBack(dotView!)
                }
            }
        }
    

    @IBAction func showDeviceList() {
        let deviceList = DeviceList()
        deviceList.onDeviceSelected = { [weak self] device in
            print("Selected device: \(device)")
            self?.device = device
            self?.sceneView.scene.rootNode.addChildNode(self?.virtualPhoneNode ?? SCNNode())
        }

        let navigationController = UINavigationController(rootViewController: deviceList)
        navigationController.modalPresentationStyle = .popover

        if let popoverPresentationController = navigationController.popoverPresentationController {
            popoverPresentationController.sourceView = deviceButton
            popoverPresentationController.sourceRect = deviceButton.bounds
            popoverPresentationController.permittedArrowDirections = .any

            // Set the popover size based on content size
            deviceList.preferredContentSize = CGSize(width: 150, height: 200)
        }

        present(navigationController, animated: true, completion: nil)
    }
    

    
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
    
    var leftPupilNode: SCNNode = {
        let geometry = SCNSphere(radius: 0.005)  // adjust radius as needed
        geometry.firstMaterial?.diffuse.contents = UIColor.red
        let node = SCNNode()
        node.geometry = geometry
        return node
    }()

    var rightPupilNode: SCNNode = {
        let geometry = SCNSphere(radius: 0.005)  // adjust radius as needed
        geometry.firstMaterial?.diffuse.contents = UIColor.red
        let node = SCNNode()
        node.geometry = geometry
        return node
    }()
    
    var lookAtTargetEyeLNode: SCNNode = SCNNode()
    var lookAtTargetEyeRNode: SCNNode = SCNNode()
    
    
    var virtualPhoneNode: SCNNode = SCNNode()
    /*
    var virtualScreenNode: SCNNode = {
        
        let screenGeometry = SCNPlane(width: 1, height: 1)
        screenGeometry.firstMaterial?.isDoubleSided = true
        screenGeometry.firstMaterial?.diffuse.contents = UIColor.green
        
        return SCNNode(geometry: screenGeometry)
    }()
    */
    

    lazy var virtualScreenNode: SCNNode = {
        
        let screenGeometry = SCNPlane(width: device.phoneScreenPointSize.width, height: device.phoneScreenPointSize.height)
        screenGeometry.firstMaterial?.isDoubleSided = true
        screenGeometry.firstMaterial?.diffuse.contents = UIColor.green
        
        return SCNNode(geometry: screenGeometry)
    }()
    
    var eyeLookAtPositionXs: [CGFloat] = []
    var eyeLookAtPositionYs: [CGFloat] = []
    
    var REyeLookAtPositionXs: [CGFloat] = []
    var LEyeLookAtPositionXs: [CGFloat] = []
    
    var REyeLookAtPositionYs: [CGFloat] = []
    var LEyeLookAtPositionYs: [CGFloat] = []
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        startRecordingEye = {
                    //start capturing data
                    self.eyeTrackingData = []
                    self.eyeTrackingStartTimestamp = CACurrentMediaTime()
                    self.eyeTrackingStartTime = Date()  // Save the start time
                    print("startRecordingEye at timestamp \(self.eyeTrackingStartTimestamp)")
                    print("startRecordingEye at time", self.eyeTrackingStartTime!)
                }
        
        stopRecordingEye = {
            self.saveEyeTrackingData()
            self.performEyeTrackingOverlay()
            self.saveEyeTrackingFixations()
                // Perform additional actions after processing is complete
            
        }
        
        //webview
        webView.customUserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:100.0) Gecko/20100101 Firefox/100.0"
        webView.load(URLRequest(url: URL(string: "https://www.youtubekids.com")!))
        webView.scrollView.bounces = false

        // Add the recording button to the container view
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(startStopRecordButtonTapped(_:)))
        recordButton.addGestureRecognizer(tapGesture)
        recordButton.isUserInteractionEnabled = true
        // containerView.addSubview(recordButton)
        
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.session.delegate = self
        sceneView.automaticallyUpdatesLighting = true
        
        sceneView.rendersContinuously = true //added
        
        // Setup Scenegraph
        sceneView.scene.rootNode.addChildNode(faceNode)
        sceneView.scene.rootNode.addChildNode(virtualPhoneNode)
        virtualPhoneNode.addChildNode(virtualScreenNode)
        faceNode.addChildNode(eyeLNode)
        faceNode.addChildNode(eyeRNode)
        eyeLNode.addChildNode(lookAtTargetEyeLNode)
        eyeRNode.addChildNode(lookAtTargetEyeRNode)
        
        eyeLNode.addChildNode(leftPupilNode)
        eyeRNode.addChildNode(rightPupilNode)
        
        // Set LookAtTargetEye at 2 meters away from the center of eyeballs to create segment vector
        lookAtTargetEyeLNode.position.z = 2
        lookAtTargetEyeRNode.position.z = 2
        
        
        // Bring the web view to the front
        view.bringSubviewToFront(webView)
        // Bring the recording button to the front
        view.bringSubviewToFront(recordButton)
        
        // Bring the eye tracking cursor to the front
        //view.bringSubviewToFront(eyePositionIndicatorView)
        // Bring the device button to the front
        view.bringSubviewToFront(deviceButton)
        
        view.bringSubviewToFront(stackView) //horizontal buttons
        
        view.bringSubviewToFront(sceneView)
        // Bring the eye tracking cursor to the front
        view.bringSubviewToFront(eyePositionIndicatorView)

        // Set up the device button to show the device list
        deviceButton.addTarget(self, action: #selector(showDeviceList), for: .touchUpInside)

        // Hide the eyePositionIndicatorView
        //eyePositionIndicatorView.isHidden = true
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
      
    
    func update(withFaceAnchor anchor: ARFaceAnchor) {
        
        eyeRNode.simdTransform = anchor.rightEyeTransform
        eyeLNode.simdTransform = anchor.leftEyeTransform
        
        // Calculate new pupil positions in the world coordinates system
        let (leftPupilPosition, rightPupilPosition) = calculatePupilPositions(leftEyeNode: eyeLNode, rightEyeNode: eyeRNode)
            
        // Convert the world coordinates to the local coordinates of the eye nodes
        let localLeftPupilPosition = eyeLNode.convertPosition(leftPupilPosition, from: nil)
        let localRightPupilPosition = eyeRNode.convertPosition(rightPupilPosition, from: nil)
            
        // Update the positions of the pupil nodes
        leftPupilNode.position = localLeftPupilPosition
        rightPupilNode.position = localRightPupilPosition
        
        // Print eye positions and orientations
        //print("Left Eye Position: \(eyeLNode.position), Orientation: \(eyeLNode.orientation)")
        //print("Right Eye Position: \(eyeRNode.position), Orientation: \(eyeRNode.orientation)")
        
        // Inside the update method
        let leftPupilSize = anchor.blendShapes[.eyeBlinkLeft]?.floatValue ?? 0.0
        let rightPupilSize = anchor.blendShapes[.eyeBlinkRight]?.floatValue ?? 0.0
        let averageEyelidValue = (leftPupilSize + rightPupilSize) / 2.0
        
        //print(leftPupilSize)
        
        var eyeLLookAt = CGPoint()
        var eyeRLookAt = CGPoint()
        
        
        ///////*********
        //let heightCompensation = CGFloat(device.heightCompensation)
        
        DispatchQueue.main.async { [self] in
           // let currentTimestamp = CACurrentMediaTime()

            // Perform Hit test using the ray segments that are drawn by the center of the eyeballs to somewhere two meters away at direction of where users look at to the virtual plane that place at the same orientation of the phone screen
            
            let phoneScreenEyeRHitTestResults = self.virtualScreenNode.hitTestWithSegment(from: self.lookAtTargetEyeRNode.worldPosition, to: self.eyeRNode.worldPosition, options: nil)
            let phoneScreenEyeLHitTestResults = self.virtualScreenNode.hitTestWithSegment(from: self.lookAtTargetEyeLNode.worldPosition, to: self.eyeLNode.worldPosition, options: nil)
           
            /*
            // For example, when you're performing the hit test:
            let phoneScreenEyeRHitTestResults = virtualPhoneNode.hitTestWithSegment(from: lookAtTargetEyeRNode.worldPosition, to: rightPupilPosition, options: nil)
            let phoneScreenEyeLHitTestResults = virtualPhoneNode.hitTestWithSegment(from: lookAtTargetEyeLNode.worldPosition, to: leftPupilPosition, options: nil)
            */
            
            for result in phoneScreenEyeRHitTestResults {
                eyeRLookAt.x = CGFloat(result.localCoordinates.x) / (self.device.phoneScreenSize.width / 2) * self.device.phoneScreenPointSize.width
                eyeRLookAt.y = CGFloat(result.localCoordinates.y) / (self.device.phoneScreenSize.height / 2) * self.device.phoneScreenPointSize.height + self.device.heightCompensation
            }
            
            for result in phoneScreenEyeLHitTestResults {
                eyeLLookAt.x = CGFloat(result.localCoordinates.x) / (self.device.phoneScreenSize.width / 2) * self.device.phoneScreenPointSize.width
                eyeLLookAt.y = CGFloat(result.localCoordinates.y) / (self.device.phoneScreenSize.height / 2) * self.device.phoneScreenPointSize.height + self.device.heightCompensation
            }
            
            // Add the latest position and keep up to 8 recent position to smooth with.
            let smoothThresholdNumber: Int = 10
            self.eyeLookAtPositionXs.append((eyeRLookAt.x + eyeLLookAt.x) / 2)
            self.eyeLookAtPositionYs.append(-(eyeRLookAt.y + eyeLLookAt.y) / 2)
            self.eyeLookAtPositionXs = Array(self.eyeLookAtPositionXs.suffix(smoothThresholdNumber))
            self.eyeLookAtPositionYs = Array(self.eyeLookAtPositionYs.suffix(smoothThresholdNumber))
            
            let smoothEyeLookAtPositionX = self.eyeLookAtPositionXs.average!
            let smoothEyeLookAtPositionY = self.eyeLookAtPositionYs.average!

            self.eyePositionIndicatorView.transform = CGAffineTransform(translationX: smoothEyeLookAtPositionX, y: smoothEyeLookAtPositionY)
            
            // update eye look at labels values
            self.lookAtPositionXLabel.text = "\(Int(round(smoothEyeLookAtPositionX + self.device.phoneScreenPointSize.width / 2)))"
            self.lookAtPositionYLabel.text = "\(Int(round(smoothEyeLookAtPositionY + self.device.phoneScreenPointSize.height / 2)))"
            //print(CGPoint(x: (smoothEyeLookAtPositionX + self.device.phoneScreenPointSize.width / 2), y: (smoothEyeLookAtPositionY + self.device.phoneScreenPointSize.height / 2)))
            
            
            // Calculate distance of the eyes to the camera
            let distanceL = self.eyeLNode.worldPosition - SCNVector3Zero
            let distanceR = self.eyeRNode.worldPosition - SCNVector3Zero
            
            // Average distance from two eyes
            let distance = (distanceL.length() + distanceR.length()) / 2
            
            // Update distance label value
            self.distanceLabel.text = "\(Int(round(distance * 100))) cm"
                
                let absoluteTimestamp = CACurrentMediaTime() - self.eyeTrackingStartTimestamp
                let newEntry = EyeTrackingData(position: CGPoint(x: smoothEyeLookAtPositionX + self.device.phoneScreenPointSize.width / 2, y: smoothEyeLookAtPositionY + self.device.phoneScreenPointSize.height / 2), timestamp: absoluteTimestamp, eyelidValue: averageEyelidValue)
                self.eyeTrackingData.append(newEntry)
            }
            
        }
    
    func calculatePupilPositions(leftEyeNode: SCNNode, rightEyeNode: SCNNode, pupilOffset: Float = 0.01) -> (leftPupilPosition: SCNVector3, rightPupilPosition: SCNVector3) {
        let leftEyePosition = leftEyeNode.worldPosition
        let rightEyePosition = rightEyeNode.worldPosition

        let leftEyeForward = SCNVector3(leftEyeNode.worldTransform.m31, leftEyeNode.worldTransform.m32, leftEyeNode.worldTransform.m33).normalized()
        let rightEyeForward = SCNVector3(rightEyeNode.worldTransform.m31, rightEyeNode.worldTransform.m32, rightEyeNode.worldTransform.m33).normalized()

        let leftPupilPosition = SCNVector3(x: leftEyePosition.x + leftEyeForward.x * pupilOffset,
                                           y: leftEyePosition.y + leftEyeForward.y * pupilOffset,
                                           z: leftEyePosition.z + leftEyeForward.z * pupilOffset)

        let rightPupilPosition = SCNVector3(x: rightEyePosition.x + rightEyeForward.x * pupilOffset,
                                            y: rightEyePosition.y + rightEyeForward.y * pupilOffset,
                                            z: rightEyePosition.z + rightEyeForward.z * pupilOffset)
                                            
        return (leftPupilPosition, rightPupilPosition)
    }

       func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
           virtualPhoneNode.transform = (sceneView.pointOfView?.transform)!
       }
       
       func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
           faceNode.transform = node.transform
           guard let faceAnchor = anchor as? ARFaceAnchor else { return }
           update(withFaceAnchor: faceAnchor)
       }
        
        
        func getDocumentsDirectory() -> URL {
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let documentsDirectory = paths[0]
            return documentsDirectory
        }
        
        func saveEyeTrackingData() {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
            let filename = "EyeTrackingData-\(dateFormatter.string(from: Date())).txt"
            let fileURL = getDocumentsDirectory().appendingPathComponent(filename)
            
            do {
                let data = try JSONEncoder().encode(eyeTrackingData)
                if let fileHandle = try? FileHandle(forWritingTo: fileURL) {
                    // Append to existing file
                    fileHandle.seekToEndOfFile()
                    fileHandle.write(data)
                    fileHandle.closeFile()
                } else {
                    // Create new file
                    try data.write(to: fileURL)
                }
                if let lastFrame = eyeTrackingData.last {
                    print("Last eye tracking frame x: \(lastFrame.position.x), y: \(lastFrame.position.y), timestamp: \(lastFrame.timestamp)")
                }
                print("Eye tracking data saved to file: \(filename)")
            } catch {
                print("Error saving eye tracking data: \(error)")
            }
        }
        func generateScreenRecordingURL() -> URL {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
            let filename = "ScreenRecording-\(dateFormatter.string(from: Date())).mov"
            let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
            return fileURL
        }
        
        //
        func performEyeTrackingOverlay() {
            // Stop capturing data
            //self.saveEyeTrackingData()
            
            // Generate the screen recording video URL
            let videoURL = self.generateScreenRecordingURL()
            
            let manager = EyeTrackingOverlayManager(videoURL: videoURL, eyeTrackingData: self.eyeTrackingData, device: self.device)
            Task {
                await manager.overlayEyeTrackingDataOnVideo { result in
                    switch result {
                    case .success(let outputURL):
                        // Handle the successful export
                        print("Video overlay completed. Output URL: \(outputURL)")
                    case .failure(let error):
                        // Handle the failure
                        print("Video overlay failed with error: \(error)")
                    }
                }
            }
        }
   
      
        //load eye tracking data
        func loadEyeTrackingData(from fileURL: URL) -> [[CGPoint]]? {
            do {
                let data = try Data(contentsOf: fileURL)
                let eyeTrackingData = try JSONDecoder().decode([[CGPoint]].self, from: data)
                return eyeTrackingData
            } catch {
                print("Error loading eye tracking data: \(error)")
                return nil
            }
        }
        
    }

/*
//ADDED 6/30
// This function takes the face node, eye name, and blink amount as inputs,
// and returns the eye position and orientation.
func extractEyeData(from faceNode: SCNNode, eyeName: String, blinkAmount: Float) -> (position: SCNVector3, orientation: SCNVector4)? {
    guard blinkAmount < 0.5, let eyeNode = faceNode.childNode(withName: eyeName, recursively: true) else {
        return nil
    }

    let eyePosition = eyeNode.position
    let eyeOrientation = eyeNode.orientation
    return (eyePosition, eyeOrientation)
}

func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
    faceNode.transform = node.transform
    
    guard let faceAnchor = anchor as? ARFaceAnchor else { return }
    update(withFaceAnchor: faceAnchor)
    
    let blendShapes = faceAnchor.blendShapes
    let leftEyeBlink = blendShapes[.eyeBlinkLeft]?.floatValue ?? 0.0
    let rightEyeBlink = blendShapes[.eyeBlinkRight]?.floatValue ?? 0.0

    if let leftEyeData = extractEyeData(from: node, eyeName: "eyeLeftNode", blinkAmount: leftEyeBlink) {
        print("Left Eye Position: \(leftEyeData.position), Orientation: \(leftEyeData.orientation)")
    }

    if let rightEyeData = extractEyeData(from: node, eyeName: "eyeRightNode", blinkAmount: rightEyeBlink) {
        print("Right Eye Position: \(rightEyeData.position), Orientation: \(rightEyeData.orientation)")
    }
}
//ADDED 6/30
 */















