//
//  EyeTrackingDataManager.swift
//  Eyes Tracking
//
//  Created by holly on 5/5/23.
//  Copyright © 2023 virakri. All rights reserved.
//

import Foundation

class EyeTrackingDataManager {
    static let shared = EyeTrackingDataManager()

    func saveEyeTrackingData(_ data: [[CGPoint]]) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        let filename = "EyeTrackingData-\(dateFormatter.string(from: Date())).txt"
        let fileURL = getDocumentsDirectory().appendingPathComponent(filename)

        do {
            let data = try JSONEncoder().encode(data)
            try data.write(to: fileURL)
            print("Eye tracking data saved to file: \(filename)")
        } catch {
            print("Error saving eye tracking data: \(error)")
        }
    }

    func loadEyeTrackingData(from fileURL: URL) -> [[CGPoint]]? {
        do {
            let data = try Data(contentsOf: fileURL)
            let eyeTrackingData = try JSONDecoder().decode([[CGPoint]].self, from: data)
            return eyeTrackingData
        } catch {
            print("Error loading eye tracking data: \(error)")
            return nil
        }
    }

    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
}
