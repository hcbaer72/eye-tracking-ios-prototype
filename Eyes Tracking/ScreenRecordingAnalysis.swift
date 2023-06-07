//
//  ScreenRecordingAnalysis.swift
//  Eyes Tracking
//
//  Created by holly on 5/31/23.
//  Copyright © 2023 virakri. All rights reserved.
//

import Foundation
import AVFoundation
import Vision


extension ViewController {
    
  //  convenience init(videoURL: URL, eyeTrackingData: [EyeTrackingData], device: Device, assetReaderOutputs: [AVAssetReaderOutput]) {
  //      self.init(videoURL: videoURL, eyeTrackingData: eyeTrackingData, device: device, assetReaderOutputs: assetReaderOutputs)
        // Other initialization code
  //  }
    
    func processFrames(videoTrack: AVAssetTrack, assetReader: AVAssetReader, fixations: [FixationData]) async {
        // Get the total number of frames in the video track
        guard let totalFrameCount = await getFrameCount(from: videoTrack) else {
            print("Failed to retrieve the total number of frames.")
            return
        }
        
        // Create an array to store fixations with associated recognized objects
        var fixationsWithObjects: [FixationData] = []
        
        // Loop through each frame of the video
        for frameIndex in 0..<totalFrameCount {
            // Load the frame from the video
            guard let frame = loadFrame(at: frameIndex, using: assetReader.outputs, assetReader: assetReader) else {
                continue
            }
            
            // Perform feature extraction using Vision
            extractFeatures(from: frame)
            
            // Iterate through the fixations and recognize objects for each fixation
            for fixation in fixations {
                // Perform object recognition using Vision for the current fixation
                do {
                    let recognizedObjects = try await recognizeObjects(in: frame, fixation: fixation)
                    
                    // Associate the recognized objects with the fixation data
                    var fixationWithObjects = fixation
                    fixationWithObjects.recognizedObjects = recognizedObjects
                    
                    // Add the fixation with associated recognized objects to the array
                    fixationsWithObjects.append(fixationWithObjects)
                    
                    // Perform further analysis or associate the recognized objects with the fixation data
                    // ...
                } catch {
                    print("Error recognizing objects for fixation: \(error)")
                }
            }
        }
        
        // Use the fixationsWithObjects array as needed
        // ...
    }
    
    
    // Retrieve the total number of frames in the video track asynchronously
    func getFrameCount(from videoTrack: AVAssetTrack) async -> Int? {
        do {
            guard let duration = try await videoTrack.asset?.load(.duration),
                  let durationInSeconds = CMTimeGetSeconds(duration) as Double?,
                  let frameRate = try await videoTrack.load(.nominalFrameRate) as Float? else {
                return nil
            }
            
            let totalFrameCount = Int(Float(durationInSeconds) * frameRate)
            return totalFrameCount
            
        } catch {
            print("Error retrieving frame count: \(error)")
            return nil
        }
        // ...
    }
    
    // Load a specific frame from the screen recording video
    func loadFrame(at index: Int, using assetReaderOutputs: [AVAssetReaderOutput], assetReader: AVAssetReader) -> CVPixelBuffer? {
        // Get the video output from the asset reader's outputs
        guard let videoOutput = assetReaderOutputs.first as? AVAssetReaderVideoCompositionOutput else {
            return nil
        }
        
        // Ensure the output has been initialized
        guard assetReader.status == .reading else {
            return nil
        }
        
        // Get the frame at the specified index
        guard let sampleBuffer = videoOutput.copyNextSampleBuffer() else {
            return nil
        }
        
        let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        return pixelBuffer
    }
    
    
    // Perform feature extraction on the frame using Vision
    func extractFeatures(from frame: CVPixelBuffer) {
        // Create a Vision request for feature extraction
        let request = VNGenerateAttentionBasedSaliencyImageRequest { request, error in
            // Handle the completion of the feature extraction request
            guard error == nil else {
                print("Error performing feature extraction request: \(error!)")
                return
            }
            
            // Retrieve the attention-based saliency image from the request
            guard let result = request.results?.first as? VNPixelBufferObservation else {
                return
            }
            
            // Process the feature extraction results
            let saliencyImage = result.pixelBuffer
            
            // Perform further analysis or associate the features with the fixation data
            
            // Perform feature and image detection here using the Vision framework
            
            // Example: Perform face detection
            let faceDetectionRequest = VNDetectFaceRectanglesRequest { request, error in
                guard error == nil else {
                    print("Error performing face detection: \(error!)")
                    return
                }
                
                guard let results = request.results as? [VNFaceObservation] else {
                    return
                }
                
                for faceObservation in results {
                    // Access the face bounding box, landmarks, or other attributes
                    
                    // Example: Get the bounding box of the detected face
                    let boundingBox = faceObservation.boundingBox
                    
                    // Perform further analysis or associate the detected face with the fixation data
                }
            }
            
            // Create a Vision request handler for the current frame
            let requestHandler = VNImageRequestHandler(cvPixelBuffer: frame, options: [:])
            
            // Perform the face detection request
            do {
                try requestHandler.perform([faceDetectionRequest])
            } catch {
                print("Error performing face detection: \(error)")
            }
        }
        
        // Create a Vision request handler for the current frame
        let requestHandler = VNImageRequestHandler(cvPixelBuffer: frame, options: [:])
        
        // Perform the feature extraction request
        do {
            try requestHandler.perform([request])
        } catch {
            print("Error performing feature extraction request: \(error)")
        }
    }

    // Perform object recognition on the frame using Vision
    func recognizeObjects(in frame: CVPixelBuffer, fixation: FixationData) async throws -> [RecognizedObject] {
        // Create a Vision request for object recognition
        let textRecognitionRequest = VNRecognizeTextRequest { request, error in
            // Handle the completion of the object recognition request
            guard error == nil else {
                print("Error performing object recognition request: \(error!)")
                return
            }
            
            // Retrieve the recognized text observations from the request
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                return
            }
            
            // Process the object recognition results
            for observation in observations {
                let recognizedText = observation.topCandidates(1).first?.string

                // Perform further analysis or associate the recognized objects with the fixation data

                // Example: Perform object tracking
                let objectTrackingRequest = VNTrackObjectRequest(detectedObjectObservation: observation) { request, error in
                    guard error == nil else {
                        print("Error performing object tracking: \(error!)")
                        return
                    }

                    guard let trackedObjectObservation = request.results?.first as? VNRecognizedObjectObservation else {
                        return
                    }

                    // Access the tracked object's bounding box, label, or other attributes

                    // Example: Get the label of the tracked object
                    let label = trackedObjectObservation.labels.first?.identifier
                    
                    let boundingBox = CGRect(x: 0, y: 0, width: 50, height: 50)
                    
                    // Create a RecognizedObject instance with label and confidence
                    var recognizedObject = RecognizedObject(label: label ?? "", confidence: trackedObjectObservation.confidence, boundingBox: boundingBox)

                    // Assign the bounding box to the RecognizedObject instance
                    recognizedObject.boundingBox = trackedObjectObservation.boundingBox

                    // Perform further analysis or associate the tracked object with the fixation data

                    // Call a function to analyze the recognized object and fixation data
                    self.analyzeRecognizedObject(recognizedObject, fixation: fixation)
                }

                // Create a Vision request handler for the current frame
                let requestHandler = VNImageRequestHandler(cvPixelBuffer: frame, orientation: .up, options: [:])

                // Perform the object tracking request asynchronously
                DispatchQueue.global().async {
                    do {
                        try requestHandler.perform([objectTrackingRequest])
                    } catch {
                        print("Error performing object tracking: \(error)")
                    }
                }
            }
        }

        // Create a Vision request handler for the current frame
        let requestHandler = VNImageRequestHandler(cvPixelBuffer: frame, orientation: .up, options: [:])

        // Perform the object recognition request
        do {
            try requestHandler.perform([textRecognitionRequest])
            
            // Retrieve the recognized objects from the request
            guard let results = textRecognitionRequest.results as? [VNRecognizedObjectObservation] else {
                return []
            }
            
            // Process the recognized objects and create an array of RecognizedObject instances
            var recognizedObjects: [RecognizedObject] = []
            
            for result in results {
                let boundingBox = CGRect(x: 0, y: 0, width: 50, height: 50)
                
                var recognizedObject = RecognizedObject(label: result.labels.first?.identifier ?? "", confidence: result.confidence, boundingBox: boundingBox)
                
                // Retrieve the bounding box of the recognized object from 'result'
                let resultBoundingBox = result.boundingBox
                
                // Associate the bounding box with the recognized object
                recognizedObject.boundingBox = resultBoundingBox
                
                recognizedObjects.append(recognizedObject)
            }
            
            return recognizedObjects
        } catch {
            print("Error performing object recognition request: \(error)")
            throw error
        }
    }
    
    
    func processFixationsWithImageAnalysis(completion: @escaping () -> Void) async {
        // Ensure that the fixations data is available
        guard !fixations.isEmpty else {
            print("Fixations data is empty.")
            completion()
            return
        }
        
        // Load the screen recording video
        guard let videoURL = self.videoURL else {
            print("VideoURL is nil. Make sure it is set before calling processFixationsWithImageAnalysis.")
            completion()
            return
        }
        
        let asset = AVAsset(url: videoURL)
        
        do {
            // Get the video track from the asset
            guard let videoTrack = try await getVideoTrack(from: asset) else {
                print("Failed to retrieve the video track from the asset.")
                completion()
                return
            }
            
            // Create an asset reader for the video
            do {
                let assetReader = try AVAssetReader(asset: asset)
                
                // Add video output to the asset reader
                let videoOutput = AVAssetReaderTrackOutput(track: videoTrack, outputSettings: nil)
                assetReader.add(videoOutput)
                
                // Start the asset reader
                assetReader.startReading()
                
                // Array to store fixations with associated recognized objects
                var fixationsWithObjects: [FixationData] = []
                
                // Process each fixation
                for fixation in fixations {
                    // Map fixation coordinates to the screen recording video frame
                    guard let videoFrameIndex = try await mapFixationToVideoFrame(fixation: fixation, videoTrack: videoTrack) else {
                        continue
                    }
                    
                    // Load the frame from the video
                    guard let frame = loadFrame(at: videoFrameIndex, using: assetReader.outputs, assetReader: assetReader) else {
                        continue
                    }
                    
                    // Perform feature extraction using Vision
                    extractFeatures(from: frame)
                    
                    // Perform object recognition using Vision
                    guard let recognizedObjects = try await recognizeObjects(in: frame, fixation: fixation) else {
                        continue
                    }
                    
                    // Associate the recognized objects with the fixation data
                    var fixationWithObjects = fixation
                    fixationWithObjects.recognizedObjects = recognizedObjects
                    
                    // Add the fixation with associated recognized objects to the array
                    fixationsWithObjects.append(fixationWithObjects)
                    
                    // Perform further analysis or associate the recognized objects with the fixation data
                    // ...
                }
                
                // Finish reading the asset
                assetReader.cancelReading()
                
                // Use the fixationsWithObjects array as needed
                // ...
                
                completion()
            } catch {
                print("Error creating or reading the asset: \(error)")
                completion()
            }
        } catch {
            print("Error loading the asset: \(error)")
            completion()
        }
    }
    
        // Other functions...
    func analyzeRecognizedObject(_ object: RecognizedObject, fixation: FixationData) {
        // Perform analysis of the recognized object and fixation data
        // ...
        // Example: Print the label and bounding box of the recognized object
        print("Recognized Object Label: \(object.label)")
        print("Bounding Box: \(object.boundingBox)")
    }

    func mapFixationToVideoFrame(fixation: FixationData, videoTrack: AVAssetTrack) async throws -> Int {
        let fixationStartTime = fixation.startTime
        let frameRate = try await getFrameRate(from: videoTrack)
        
        let frameRateInSeconds = TimeInterval(frameRate)
        let videoFrameIndex = Int(fixationStartTime * frameRateInSeconds)
        return videoFrameIndex
    }
    
    // Function to write the identified objects and features along with fixation analysis to a text file
    func writeIdentifiedObjectsWithFixationAnalysis(objects: [RecognizedObject], fixations: [FixationData]) {
        // Generate the fixation analysis string
        var analysisString = "Fixation Duration Analysis:\n\n"
        
        for (index, fixation) in fixations.enumerated() {
            analysisString += "Fixation \(index + 1):\n"
            analysisString += "Start Time: \(fixation.startTime)\n"
            analysisString += "Duration: \(fixation.duration) seconds\n"
            analysisString += "Center: (\(fixation.center.x), \(fixation.center.y))\n\n"
        }
        
        // Convert the fixations and recognized objects data to string format
        var fileContent = ""
        
        for (index, fixation) in fixations.enumerated() {
            fileContent += "Fixation \(index + 1):\n"
            fileContent += "Timestamp: \(fixation.startTime)\n"
            fileContent += "Duration: \(fixation.duration)\n"
            fileContent += "Center: (\(fixation.center.x), \(fixation.center.y))\n"
            
            let recognizedObjects = fixation.recognizedObjects
            
            if !recognizedObjects.isEmpty {
                fileContent += "Recognized Objects:\n"
                
                for object in recognizedObjects {
                    fileContent += "Label: \(object.label)\n"
                    fileContent += "Confidence: \(object.confidence)\n"
                    fileContent += "Bounding Box: \(object.boundingBox)\n"
                    fileContent += "\n"
                }
            }
            
            fileContent += "\n"
        }
        
        // Combine the fixation analysis and recognized objects data
        let finalContent = analysisString + "\n\n" + fileContent
        
        // Write the combined content to the text file
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        let filename = "FixationAnalysis-\(dateFormatter.string(from: Date())).txt"
        let fileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(filename)
        
        do {
            try finalContent.write(to: fileURL, atomically: true, encoding: .utf8)
            print("Fixation analysis and identified objects saved to file: \(filename)")
        } catch {
            print("Error writing to file: \(error)")
        }
    }
    // Retrieve the frame rate from the given AVAssetTrack asynchronously
    func getFrameRate(from videoTrack: AVAssetTrack) async throws -> Float {
        return try await videoTrack.load(.nominalFrameRate)
    }
    // Retrieve the video track from the given AVAsset asynchronously
    func getVideoTrack(from asset: AVAsset) async throws -> AVAssetTrack? {
        let videoTracks = try await asset.loadTracks(withMediaType: .video)
        return videoTracks.first
    }
    
}
