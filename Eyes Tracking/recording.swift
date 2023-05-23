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



//MARK: App recording extensions
extension View{
    
    // MARK: Start Recording
    func startRecording(enableMicrophone: Bool = false, completion: @escaping(Error?)->()){
        let recorder = RPScreenRecorder.shared()
        
        //Microphone Option
        recorder.isMicrophoneEnabled = false
        
        //Starting Recording
        recorder.startRecording(handler: completion)
        
    }
    
    //MARK: Stop recording
    //it will return the Recorded Video URL
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
    
    
    //MARK: cancel recording
  //  func cancelRecording(){
  //      let recorder = RPScreenRecorder.shared()
   //     recorder.discardRecording{}
  //  }
}
