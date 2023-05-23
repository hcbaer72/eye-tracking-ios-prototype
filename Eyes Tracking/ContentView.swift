//
//  ContentView.swift
//  Eyes Tracking
//
//  Created by holly on 4/22/23.
//  Copyright © 2023 virakri. All rights reserved.
//

import SwiftUI
import ReplayKit
import Photos

//add variables that allow us to accept closure
//viewcontroller supplies code that starts and stops the saving of data to the file
//contentview would execute code when button is pressed

//var screenRecordingStartTime: Date?

struct ContentView: View {
    var startRecordingEye: (()->())? //contentview can accept optional parameter
    var stopRecordingEye: (()->())?
    
    @State private var startRecord = false
    @State private var stopRecord = false
    
    // Recording status
    @State var isRecording: Bool = false
    @State var url: URL?
    @State var screenRecordingStartTime: Date? = nil
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                    //recording button
                        //MARK: Recording button
                        Button {
                            if isRecording{
                                //stopping since its async task
                                Task{
                                    do{
                                        self.url = try await stopRecording()
                                        self.stopRecordingEye?()
                                        print(self.url)
                                        
                                        //stop screen recording
                                        isRecording = false
                                        print("is recording: \(isRecording) ")
 
                                    }
                                    catch{
                                        print(error.localizedDescription)
                                    }
                                }
                            }
                            else{
                                startAllRecordings()
                                
                            }
                        } label: {
                            Image(systemName: isRecording ? "record.circle.fill" : "record.circle")
                                .font(.largeTitle)
                                .foregroundColor(isRecording ? .red : .green)
                        }
                    }
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
            startRecordingEye?() // Assuming this has a similar error handling mechanism

            // If both recordings are successful, update the state
            isRecording = true
            print("is recording: \(isRecording) ")
        }
    }
        
        struct ContentView_Previews: PreviewProvider {
            static var previews: some View {
                ContentView()
            }
        }
    }
