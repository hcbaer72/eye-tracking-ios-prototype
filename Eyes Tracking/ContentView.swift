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


struct ContentView: View {
    @State private var startRecord = false
    @State private var stopRecord = false
    
    
    // Recording status
    @State var isRecording: Bool = false
    @State var url: URL?
    //   let eyeTracking = EyeTracking(configuration: Configuration(appID: "ios-eye-tracking-example", blendShapes: [.eyeBlinkLeft, .eyeBlinkRight]))
    
    var body: some View {
        ZStack {
            
            VStack(spacing: 0) {
                /* Here I created a text field that takes string value and when send
                 button is clicked 'viewModel.valuePublisher' sends that value to WebView
                 then WebView sends that value to web app that you will load. In this
                 project's local .html file can not receive it because it is static you should
                 test with a web app then it will work because static website can not receive values
                 at runtime where dynamic web app can */
                    //recording button
                        //MARK: Recording button
                        Button {
                            if isRecording{
                                //stopping since its async task
                                Task{
                                    do{
                                        self.url = try await stopRecording()
                                        print(self.url)
                                        
                                        //stop screen recording
                                        isRecording = false
                                        print("is recording: \(isRecording) ")
                                        
                                        //stop eye tracking
                                        //      eyeTracking.endSession()
                                        
                                        
                                        // Exports all `Session`s as a `String`, converting the keys to snake case
                                        // ***let stringSessions = try? EyeTracking.exportAllString(with: .convertToSnakeCase)
                                        
                                        
                                    }
                                    catch{
                                        print(error.localizedDescription)
                                    }
                                }
                            }
                            else{
                                startRecording { error in
                                    if let error = error{
                                        print(error.localizedDescription)
                                        return
                                    }
                                    //success
                                    //start screen recording
                                    isRecording = true
                                    print("is recording: \(isRecording) ")
                                    
                                    //                                    //start eye tracking
                                    //                                    eyeTracking.startSession()
                                    //
                                    //                                    //show eye tracking pointer
                                    //                                   eyeTracking.pointer.backgroundColor = .red
                                    //                                    eyeTracking.showPointer()
                                    
                                    
                                }
                                
                            }
                        } label: {
                            Image(systemName: isRecording ? "record.circle.fill" : "record.circle")
                                .font(.largeTitle)
                                .foregroundColor(isRecording ? .red : .green)
                        }
                        
                    }
                    
                    //}.onReceive(self.viewModel.showLoader.receive(on: //RunLoop.main)) { value in
                    //self.showLoader = value
                    //}
                    
                    // A simple loader that is shown when WebView is loading any page and hides when loading is finished.
                    //   if showLoader {
                    //     Loader()
                    // }
            }
        }
        
        struct ContentView_Previews: PreviewProvider {
            static var previews: some View {
                ContentView()
            }
        }
    }