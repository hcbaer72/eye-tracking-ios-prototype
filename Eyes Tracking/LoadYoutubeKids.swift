//
//  LoadYoutubeKids.swift
//  Eyes Tracking
//
//  Created by holly on 6/11/23.
//  Copyright © 2023 virakri. All rights reserved.
//

import Foundation
import WebKit

extension ViewController {
    func loadYouTubeKids() {
        guard let htmlURL = Bundle.main.url(forResource: "youtubekids", withExtension: "html") else {
            print("Failed to load HTML file")
            return
        }

        webView.loadFileURL(htmlURL, allowingReadAccessTo: htmlURL)
    }
    

}
