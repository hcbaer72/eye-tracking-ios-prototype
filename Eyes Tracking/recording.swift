//
//  recording.swift
//  Eyes Tracking
//
//  Created by holly on 4/22/23.
//  Copyright © 2023 virakri. All rights reserved.
//

import Foundation
import SwiftUI
import ReplayKit
import AVFoundation



extension View {
    // MARK: Start Recording
    func startRecording(enableMicrophone: Bool = false, completion: @escaping (Error?) -> Void) {
        let recorder = RPScreenRecorder.shared()
        
        // Microphone Option
        recorder.isMicrophoneEnabled = enableMicrophone
        
        // Starting Recording
        recorder.startRecording(handler: { error in
            if error == nil {
                // Record the start time when recording starts
                let startTime = Date()
                // Save the start time to user defaults or any other suitable storage mechanism
                UserDefaults.standard.set(startTime, forKey: "ScreenRecordingStartTime")
            }
            
            completion(error)
        })
    }
    
    // MARK: Stop recording
    // It will return the Recorded Video URL
    func stopRecording() async throws -> URL {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        let filename = "ScreenRecording-\(dateFormatter.string(from: Date())).mov"
        let fileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(filename)
        
        let recorder = RPScreenRecorder.shared()
        do {
            try await recorder.stopRecording(withOutput: fileURL, completionHandler: { error in
                if error == nil {
                    // Retrieve the start time from user defaults or the storage mechanism you used
                    if let startTime = UserDefaults.standard.object(forKey: "ScreenRecordingStartTime") as? Date {
                        // Create an instance of AVAsset and add the start time as metadata
                        let asset = AVAsset(url: fileURL)
                        var metadata = [AVMetadataItem]()
                        let item = AVMutableMetadataItem()
                        item.keySpace = AVMetadataKeySpace.common
                        item.key = AVMetadataKey.commonKeyCreationDate as NSCopying & NSObjectProtocol
                        item.value = startTime as NSCopying & NSObjectProtocol
                        metadata.append(item)
                        
                        // Export the video file with the custom metadata
                        let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetPassthrough)
                        exporter?.outputFileType = .mov
                        exporter?.outputURL = fileURL
                        exporter?.metadata = metadata
                        exporter?.exportAsynchronously(completionHandler: {
                            // Handle the export completion and any errors
                        })
                    }
                    
                    // Clear the start time from user defaults or the storage mechanism
                    UserDefaults.standard.removeObject(forKey: "ScreenRecordingStartTime")
                }
            })
        } catch {
            print(error.localizedDescription)
            throw error
        }
        
        print("Screen recording saved to file: \(filename)")
        return fileURL
    }
}
  
    

    
    
    //MARK: cancel recording
  //  func cancelRecording(){
  //      let recorder = RPScreenRecorder.shared()
   //     recorder.discardRecording{}
  //  }

