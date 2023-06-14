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
    
    //sliders
    @IBOutlet weak var mySliderLeye: UISlider!
    @IBOutlet weak var mySliderReye: UISlider!
    @IBOutlet weak var mySliderDistance: UISlider!
    @IBOutlet weak var mySliderBrightness: UISlider!
    @IBOutlet weak var sliderView: UIStackView!
    
    let minZ: Float = 0.1
    let maxZ: Float = 3.0
    let defaultZ: Float = 2.0
    
    
    //bears
    @IBOutlet var upperLeftCornerBear: UIView!
    @IBOutlet var upperRightCornerBear: UIView!
    @IBOutlet var lowerLeftCornerBear: UIView!
    @IBOutlet var lowerRightCornerBear: UIView!
    
    @IBOutlet var upperLeftCornerBearLabel: UILabel!
    @IBOutlet var upperRightCornerBearLabel: UILabel!
    @IBOutlet var lowerLeftCornerBearLabel: UILabel!
    @IBOutlet var lowerRightCornerBearLabel: UILabel!
    

    var calibrationManager: CalibrationManager?
    
    //button horizontal stack view
    @IBOutlet weak var stackView: UIStackView!
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        if calibrationManager?.calibrationPhase == .notStarted {
            // Start the calibration
            calibrationManager?.startCalibration()
        } else {
            // Toggle the visibility of calibration views
            calibrationManager?.buttonPressed()
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
    
    @IBAction func brightnessSliderValueChanged(_ sender: UISlider) {
        let brightness = sender.value
        print("Brightness changed to \(brightness)")
        
        // Adjust the material properties of eyeLNode
        if let eyeLMaterial = eyeLNode.geometry?.firstMaterial {
            eyeLMaterial.lightingModel = .physicallyBased
            eyeLMaterial.diffuse.contentsTransform = SCNMatrix4MakeScale(1.0, 1.0, 0.0)
            eyeLMaterial.diffuse.intensity = CGFloat(brightness)
        }
        
        // Adjust the material properties of eyeRNode
        if let eyeRMaterial = eyeRNode.geometry?.firstMaterial {
            eyeRMaterial.lightingModel = .physicallyBased
            eyeRMaterial.diffuse.contentsTransform = SCNMatrix4MakeScale(1.0, 1.0, 0.0)
            eyeRMaterial.diffuse.intensity = CGFloat(brightness)
        }
    }
    func setupBrightnessSlider() {
        mySliderBrightness.minimumValue = 0.0
        mySliderBrightness.maximumValue = 1.0
        mySliderBrightness.value = 0.5 // Set an initial brightness value

        mySliderBrightness.addTarget(self, action: #selector(brightnessSliderValueChanged(_:)), for: .valueChanged)
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
    
    var lookAtTargetEyeLNode: SCNNode = SCNNode()
    var lookAtTargetEyeRNode: SCNNode = SCNNode()
    
    
    var virtualPhoneNode: SCNNode = SCNNode()
    var virtualScreenNode: SCNNode = {
        
        let screenGeometry = SCNPlane(width: 1, height: 1)
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
            self.performEyeTrackingDataAnalysis()
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
        
        // Set LookAtTargetEye at 2 meters away from the center of eyeballs to create segment vector
        lookAtTargetEyeLNode.position.z = 2
        lookAtTargetEyeRNode.position.z = 2
        
        mySliderLeye.value = normalZ(defaultZ)
        mySliderReye.value = normalZ(defaultZ)

        mySliderLeye.addTarget(self, action: #selector(mySliderLeyeValueChanged(_:)), for: .valueChanged)
        mySliderReye.addTarget(self, action: #selector(mySliderReyeValueChanged(_:)), for: .valueChanged)
        setupBrightnessSlider()
 
        // Bring the web view to the front
        view.bringSubviewToFront(webView)
        // Bring the recording button to the front
        view.bringSubviewToFront(recordButton)
        
        // Bring the eye tracking cursor to the front
        view.bringSubviewToFront(eyePositionIndicatorView)
        // Bring the device button to the front
        view.bringSubviewToFront(deviceButton)
        
        view.bringSubviewToFront(stackView) //horizontal buttons
        view.bringSubviewToFront(sliderView) //sliders
        
        // Set up the device button to show the device list
        deviceButton.addTarget(self, action: #selector(showDeviceList), for: .touchUpInside)
        
        calibrationManager = CalibrationManager(viewController: self)
        // Hide the eyePositionIndicatorView
        //eyePositionIndicatorView.isHidden = true
    }
    
    
    @objc func mySliderLeyeValueChanged(_ sender: UISlider) {
    lookAtTargetEyeLNode.position.z = zFromNormal(sender.value)
    //print("Slider value changed to \(sender.value)")
}
    @objc func mySliderReyeValueChanged(_ sender: UISlider) {
    lookAtTargetEyeRNode.position.z = zFromNormal(sender.value)
}
    
    func normalZ(_ value: Float) -> Float {
    let offset = minZ
    let adjustedValue = value - offset
    let domainWidth = maxZ - minZ
    return adjustedValue / domainWidth
}
    func zFromNormal(_ value: Float) -> Float {
    let domainWidth = maxZ - minZ
    let adjustedValue = value * domainWidth
    return adjustedValue + minZ
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
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let faceAnchor = anchor as? ARFaceAnchor, let faceGeometry = node.geometry as? ARSCNFaceGeometry else {
            return }
        faceNode.transform = node.transform
        
        update(withFaceAnchor: faceAnchor)
        
        
        var leftEyeTransform: simd_float4x4 { get {
            return faceAnchor.leftEyeTransform }
            
            
        }
        //print("Left Eye: \(faceAnchor.leftEyeTransform)")
        
        for x in 0..<1220 {
            let child = node.childNode(withName: "\(x)", recursively: false)
            child?.position = SCNVector3(faceAnchor.geometry.vertices[x])
        }
        
        faceGeometry.update(from: faceAnchor.geometry)
    }
    
    // MARK: - update(ARFaceAnchor)
    
    func update(withFaceAnchor anchor: ARFaceAnchor) {
        
        eyeRNode.simdTransform = anchor.rightEyeTransform
        eyeLNode.simdTransform = anchor.leftEyeTransform
        
        // Inside the update method
        let leftPupilSize = anchor.blendShapes[.eyeBlinkLeft]?.floatValue ?? 0.0
        let rightPupilSize = anchor.blendShapes[.eyeBlinkRight]?.floatValue ?? 0.0
        let averageEyelidValue = (leftPupilSize + rightPupilSize) / 2.0
        
        //print(leftPupilSize)
        
        var eyeLLookAt = CGPoint()
        var eyeRLookAt = CGPoint()
        
        
        ///////*********
        //let heightCompensation = CGFloat(device.heightCompensation)
        
        DispatchQueue.main.async {
            let currentTimestamp = CACurrentMediaTime()

            // Perform Hit test using the ray segments that are drawn by the center of the eyeballs to somewhere two meters away at direction of where users look at to the virtual plane that place at the same orientation of the phone screen
            
            let phoneScreenEyeRHitTestResults = self.virtualPhoneNode.hitTestWithSegment(from: self.lookAtTargetEyeRNode.worldPosition, to: self.eyeRNode.worldPosition, options: nil)
            let phoneScreenEyeLHitTestResults = self.virtualPhoneNode.hitTestWithSegment(from: self.lookAtTargetEyeLNode.worldPosition, to: self.eyeLNode.worldPosition, options: nil)
            
            for result in phoneScreenEyeRHitTestResults {
                eyeRLookAt.x = CGFloat(result.localCoordinates.x) / (self.device.phoneScreenSize.width / 2) * self.device.phoneScreenPointSize.width
                eyeRLookAt.y = CGFloat(result.localCoordinates.y) / (self.device.phoneScreenSize.height / 2) * self.device.phoneScreenPointSize.height + self.device.heightCompensation
            }
            
            for result in phoneScreenEyeLHitTestResults {
                eyeLLookAt.x = CGFloat(result.localCoordinates.x) / (self.device.phoneScreenSize.width / 2) * self.device.phoneScreenPointSize.width
                eyeLLookAt.y = CGFloat(result.localCoordinates.y) / (self.device.phoneScreenSize.height / 2) * self.device.phoneScreenPointSize.height + self.device.heightCompensation
            }
            
            // Add the latest position and keep up to 8 recent position to smooth with.
            let smoothThresholdNumber: Int = 8
            self.eyeLookAtPositionXs.append((eyeRLookAt.x + eyeLLookAt.x) / 2)
            self.eyeLookAtPositionYs.append(-(eyeRLookAt.y + eyeLLookAt.y) / 2)
            self.eyeLookAtPositionXs = Array(self.eyeLookAtPositionXs.suffix(smoothThresholdNumber))
            self.eyeLookAtPositionYs = Array(self.eyeLookAtPositionYs.suffix(smoothThresholdNumber))
            
            let smoothEyeLookAtPositionX = self.eyeLookAtPositionXs.average!
            let smoothEyeLookAtPositionY = self.eyeLookAtPositionYs.average!

           // self.eyePositionIndicatorView.transform = CGAffineTransform(translationX: smoothEyeLookAtPositionX, y: smoothEyeLookAtPositionY)
            
            if let adjustedEyePosition = self.calibrationManager?.getAdjustedEyePosition(rawEyePosition: CGPoint(x: smoothEyeLookAtPositionX, y: smoothEyeLookAtPositionY)) {
                self.eyePositionIndicatorView.transform = CGAffineTransform(translationX: adjustedEyePosition.x, y: adjustedEyePosition.y)
            }
            
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

        func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
            virtualPhoneNode.transform = (sceneView.pointOfView?.transform)!
            
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
    func performEyeTrackingDataAnalysis() {
        // Generate the screen recording video URL
        let videoURL = self.generateScreenRecordingURL()
        
        let objectManager = ObjectManager(videoURL: videoURL, eyeTrackingData: self.eyeTrackingData)
        Task{
            await objectManager.processEyeTrackingDataWithImageAnalysis { result in
                switch result {
                case .success(let outputURL):
                    // Handle the successful completion
                    print("Video analysis completed. Output URL: \(outputURL)")
                case .failure(let error):
                    // Handle the failure
                    print("Video analysis failed with error: \(error)")
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

//When the screen recording is finished, read the saved eye tracking data from the file.
//Parse the eye tracking data and map it to the time codes of the screen recording frames.
//Create a custom UIView subclass that draws the eye tracking data on top of the WKWebView. You can use Core Graphics to draw lines, circles, or any other shapes you want to show the eye movements.
//Use AVFoundation to create a video composition that combines the screen recording with the eye tracking data overlay. You can use the AVMutableVideoComposition class to create a composition, and AVMutableVideoCompositionLayerInstruction to add the overlay on top of the screen recording.
//Export the composition to a video file using AVAssetExportSession.

/*
extension ViewController {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let webViewContentWidth: CGFloat = webView.scrollView.contentSize.width
        let viewWidth: CGFloat = view.frame.width
        var scale: CGFloat = 0.8
        print(webViewContentWidth)
        print(viewWidth)
               
        scale = viewWidth / webViewContentWidth
        
        let script = """
        var style = document.createElement('style');
        style.innerHTML = 'body { min-width: 0px; max-width: 100%; transform: scale(\(scale)); transform-origin: 0 0; position: absolute; left: 0; }';
        document.head.appendChild(style);
        """
        
        webView.evaluateJavaScript(script) { result, error in
            if let error = error {
                print("JavaScript execution error:", error.localizedDescription)
            } else {
                print("JavaScript execution successful")
            }
        }
    }
}
 */
/*
extension ViewController {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let script = """
            function getMinWidth() {
                var bodyStyle = window.getComputedStyle(document.body);
                var bodyMinWidth = bodyStyle.getPropertyValue('min-width');
                
                // Try getting the scrollWidth of the document
                var documentScrollWidth = document.documentElement.scrollWidth;
                
                return {bodyMinWidth: bodyMinWidth, documentScrollWidth: documentScrollWidth};
            }
        
            getMinWidth();
        """
        
        webView.evaluateJavaScript(script) { result, error in
            if let error = error {
                print("JavaScript execution error:", error.localizedDescription)
            } else if let dictionary = result as? [String: Any] {
                print("Body min-width:", dictionary["bodyMinWidth"] ?? "unknown")
                print("Document scrollWidth:", dictionary["documentScrollWidth"] ?? "unknown")
            }
        }
    }
}
 */













