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
    func stopRecording()async throws->URL{
        //file will be stored in temporary directory

       let url : URL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("\(UUID().description).mov")
        
        let recorder = RPScreenRecorder.shared()
        try await recorder.stopRecording(withOutput: url)
        
        return url
    }
  
    

    
    
    //MARK: cancel recording
  //  func cancelRecording(){
  //      let recorder = RPScreenRecorder.shared()
   //     recorder.discardRecording{}
  //  }
}
