//
//  ImageEffects+extensions.swift
//  Pods
//
//  Created by Antoine Cœur on 07/08/2017.
//
//

import UIKit

extension UIView {
    /// Get a UIImage from the UIView
    open func renderImage() -> UIImage {
        if #available(iOS 10.0, *) {
            // iOS 10+: UIGraphicsImageRenderer
            return UIGraphicsImageRenderer(size: bounds.size).image { layer.render(in: $0.cgContext) }
        } else {
            // Fallback on earlier versions
            // The following methods will only return a 8-bit per channel context in the DeviceRGB color space.
            // Any new bitmap drawing code is encouraged to use UIGraphicsImageRenderer in lieu of this API.
            UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0)
            defer { UIGraphicsEndImageContext() }
            layer.render(in: UIGraphicsGetCurrentContext()!)
            return UIGraphicsGetImageFromCurrentImageContext()!
        }
    }
}
