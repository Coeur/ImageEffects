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
    /// - parameter opaque:
    /// A Boolean flag indicating whether the image is opaque. Specify true to ignore the alpha channel. Specify false to handle any partially transparent pixels.
    /// - parameter scale:
    /// The scale factor to apply to the image. If you specify a value of 0.0, the scale factor is set to the scale factor of the device’s main screen.
    open func renderImage(opaque: Bool = false, scale: CGFloat = 0) -> UIImage {
        if #available(iOS 10.0, tvOS 10.0, *) {
            let format = UIGraphicsImageRendererFormat.default()
            format.opaque = opaque
            format.scale = scale
            return UIGraphicsImageRenderer(size: bounds.size, format: format).image { layer.render(in: $0.cgContext) }
        } else {
            // Fallback on earlier versions
            // The following methods will only return a 8-bit per channel context in the DeviceRGB color space.
            // Any new bitmap drawing code is encouraged to use UIGraphicsImageRenderer in lieu of this API.
            UIGraphicsBeginImageContextWithOptions(bounds.size, opaque, scale)
            defer { UIGraphicsEndImageContext() }
            layer.render(in: UIGraphicsGetCurrentContext()!)
            return UIGraphicsGetImageFromCurrentImageContext()!
        }
    }
}
