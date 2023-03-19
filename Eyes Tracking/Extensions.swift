//
//  SCNVectorExtension.swift
//  Face-based Game Prototype
//
//  Created by VIRAKRI JINANGKUL on 10/31/17.
//  Copyright © 2017 VIRAKRI JINANGKUL. All rights reserved.
//

import SceneKit
import simd

extension SCNVector3 {
    func length() -> Float {
        return sqrtf(x * x + y * y + z * z)
    }
}

func - (l: SCNVector3, r: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(l.x - r.x, l.y - r.y, l.z - r.z)
}

extension Collection where Element == CGFloat, Index == Int {
    /// Return the mean of a list of CGFloat. Used with `recentVirtualObjectDistances`.
    var average: CGFloat? {
        guard !isEmpty else {
            return nil
        }
        
        let sum = reduce(CGFloat(0)) { current, next -> CGFloat in
            return current + next
        }
        
        return sum / CGFloat(count)
    }
}

//* The transformation in ARKit is column-major, which means for transformation matrix m,
//* m[i] is the ith column of the matrix, and m[i][j] is the elements in the ith column and jth row
//* In addition, (m[3][0], m[3][1], m[3][2], m[3][3]) holds the translation amount in x, y, and z direction respectively.
//*/
extension matrix_float4x4: CustomStringConvertible {
   public var debugDescription: String {
       let m = self
       return """
       \(m[0][0]), \(m[1][0]), \(m[2][0]), \(m[3][0])
       \(m[0][1]), \(m[1][1]), \(m[2][1]), \(m[3][1])
       \(m[0][2]), \(m[1][2]), \(m[2][2]), \(m[3][2])
       \(m[0][3]), \(m[1][3]), \(m[2][3]), \(m[3][3])
       """
   }
   public var description: String {
       return self.debugDescription
   }
   public static let identity: matrix_float4x4 = matrix_float4x4(columns: (simd_float4(1, 0, 0, 0), simd_float4(0, 1, 0, 0), simd_float4(0, 0, 1, 0), simd_float4(0, 0, 0, 1)))
}

extension BinaryInteger {
   var degreesToRadians: Float {
       return Float(Int(self)) * .pi / 180.0
   }
}

extension FloatingPoint {
   var degreesToRadians: Self { return self * .pi / 180 }
   var radiansToDegrees: Self { return self * 180 / .pi }
}

