//
//  extensionscreenrecord.swift
//  Eyes Tracking
//
//  Created by holly on 3/3/23.
//  Copyright © 2023 virakri. All rights reserved.
//


import Foundation
import SwiftUI
import ReplayKit
import AVFoundation
import WebKit

//MARK: App recording extensions
extension View{
    // Create an instance of GestureRecognition class
    private var gestureRecognizer: GestureRecognition {
        GestureRecognition(webView: webView)
    }

    
    // MARK: Start Recording
    func startRecording(enableMicrophone: Bool = false, completion: @escaping(Error?)->()){
        let recorder = RPScreenRecorder.shared()
        
        //Microphone Option
        recorder.isMicrophoneEnabled = false
        
        //Starting Recording
       // recorder.startRecording(handler: completion)
        // Starting Recording
        recorder.startRecording(handler: { error in
            // Call completion handler with the error, if any
            completion(error)
            
            // Record gesture data when the screen recording starts
            let gestureData = ["type": "startRecording", "timestamp": Date()] as [String: Any]
            self.gestureRecognizer.recordGestureData(gestureData: gestureData)
        })
    }
    
    //MARK: Stop recording
    //it will return the Recorded Video URL
    func stopRecording()async throws->URL{
       let url : URL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("\(UUID().description).mov")
        
        let recorder = RPScreenRecorder.shared()
        try await recorder.stopRecording(withOutput: url)
        
        // Record gesture data when the screen recording stops
        let gestureData = ["type": "stopRecording", "timestamp": Date()] as [String: Any]
        gestureRecognizer.recordGestureData(gestureData: gestureData)
        
        return url
    }
  
    

    
    
    //MARK: cancel recording
  //  func cancelRecording(){
  //      let recorder = RPScreenRecorder.shared()
   //     recorder.discardRecording{}
  //  }
}
