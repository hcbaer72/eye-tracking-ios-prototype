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
                                startRecording { error in
                                    if let error = error{
                                        print(error.localizedDescription)
                                        return
                                    }
                                    //success
                                    //start screen recording
                                    isRecording = true
                                    print("is recording: \(isRecording) ")
                                }
                            }
                        } label: {
                            Image(systemName: isRecording ? "record.circle.fill" : "record.circle")
                                .font(.largeTitle)
                                .foregroundColor(isRecording ? .red : .green)
                        }
                    }
            }
        }
        
        struct ContentView_Previews: PreviewProvider {
            static var previews: some View {
                ContentView()
            }
        }
    }
