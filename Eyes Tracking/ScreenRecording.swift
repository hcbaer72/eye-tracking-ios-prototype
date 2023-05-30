//
//  ScreenRecording.swift
//  Eyes Tracking
//
//  Created by holly on 5/27/23.
//  Copyright © 2023 virakri. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI
import ReplayKit
import AVFoundation


extension ViewController {
    @objc func startStopRecordButtonTapped(_ sender: UITapGestureRecognizer) {
        guard let imageView = sender.view as? UIImageView else {
            return
        }

        if isRecording {
            Task {
                do {
                    self.url = try await stopRecording()
                    self.stopRecordingEye?()
                    print(self.url)
                    imageView.image = UIImage(systemName: "record.circle")
                    imageView.tintColor = .green
                    //stop screen recording
                    isRecording = false
                    print("is recording: \(isRecording) ")
                    //saveEyeTrackingData() // Save eye tracking data when recording stops
                    //performEyeTrackingOverlay() // Overlay eye tracking data on the recorded video
                } catch {
                    print(error.localizedDescription)
                }
            }
        } else {
            imageView.image = UIImage(systemName: "record.circle.fill")
            imageView.tintColor = .red
            self.startAllRecordings()
    
        }
}

    func startAllRecordings() {
        // First ensure that both recordings are not currently active
        guard !isRecording else { return }

        // Then start both recordings
        startRecording { error in
            if let error = error {
                print("Error starting screen recording: \(error.localizedDescription)")
                return
            }
            self.screenRecordingStartTime = Date()

            // Start eye tracking only if screen recording was successful
            self.startRecordingEye?() // Assuming this has a similar error handling mechanism

            // If both recordings are successful, update the state
            self.isRecording = true
            print("is recording: \(self.isRecording) ")
        }
    }
    
    func startRecording(enableMicrophone: Bool = false, completion: @escaping(Error?)->()){
        let recorder = RPScreenRecorder.shared()
        
        //Microphone Option
        recorder.isMicrophoneEnabled = false
        
        //Starting Recording
        recorder.startRecording(handler: completion)
        
    }
    
    func stopRecording() async throws -> URL {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        let filename = "ScreenRecording-\(dateFormatter.string(from: Date())).mov"
        let fileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(filename)

        let recorder = RPScreenRecorder.shared()
        do {
            try await recorder.stopRecording(withOutput: fileURL)
        } catch {
            print(error.localizedDescription)
            throw error
        }
        print("Screen recording saved to file: \(filename)")
        return fileURL
    }
}
