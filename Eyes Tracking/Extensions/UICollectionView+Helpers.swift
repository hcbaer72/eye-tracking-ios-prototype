//
//  UICollectionView+Helpers.swift
//  Eyes Tracking
//
//  Created by Kristen Lineback on 3/19/23.
//  Copyright © 2023 virakri. All rights reserved.
//

import Foundation
import UIKit

extension UICollectionView {
    func indexPath(containing view: UIView) -> IndexPath? {
        for cell in self.visibleCells where view.isDescendant(of: cell) {
            if let indexPath = self.indexPath(for: cell) {
                return indexPath
            }
        }
        return nil
    }

    func indexPath(nearestTo indexPath: IndexPath) -> IndexPath? {
        let validSections = 0..<numberOfSections
        guard validSections.contains(indexPath.section) else { return nil }

        let validItems = 0..<numberOfItems(inSection: indexPath.section)
        guard validItems.contains(indexPath.item) else {
            return self.indexPath(before: indexPath) ?? self.indexPath(after: indexPath)
        }

        return indexPath
    }

    func indexPath(after indexPath: IndexPath) -> IndexPath? {
        let validSections = 0..<numberOfSections
        guard validSections.contains(indexPath.section) else { return nil }

        let itemsInSection = numberOfItems(inSection: indexPath.section)
        let candidateIndex = indexPath.item + 1
        if candidateIndex >= itemsInSection {
            return nil
        } else {
            return IndexPath(row: candidateIndex, section: indexPath.section)
        }
    }

    func indexPath(before indexPath: IndexPath) -> IndexPath? {
        let validSections = 0..<numberOfSections
        guard validSections.contains(indexPath.section) else { return nil }

        let candidateIndex = indexPath.item - 1
        if candidateIndex < 0 {
            return nil
        } else {
            return IndexPath(row: candidateIndex, section: indexPath.section)
        }
    }
}
