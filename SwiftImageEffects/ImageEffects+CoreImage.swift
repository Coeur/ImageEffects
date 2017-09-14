//
//  ImageEffects+CoreImage.swift
//  Pods
//
//  Created by Antoine Cœur on 07/08/2017.
//
//

import UIKit
import CoreImage

#if swift(>=4.0)
#else
// swift 3 compatibility
extension CIImage {
    /* Return a new image cropped to a rectangle. */
    func cropped(to rect: CGRect) -> CIImage {
        return cropping(to: rect)
    }
}
#endif

// https://developer.apple.com/library/content/documentation/GraphicsImaging/Reference/CoreImageFilterReference/
extension UIImage {
    
    public func gaussianBlurWithCoreImage(inputRadius: Float = 10.0) -> UIImage {
        // Filter the UIImage
        let imageToFilter = ciImage ?? CIImage(cgImage: cgImage!)
        let filter = CIFilter(name: "CIGaussianBlur", withInputParameters: ["inputImage": imageToFilter,
                                                                            "inputRadius": inputRadius])!
        
        // create UIImage from filtered image (adjust rect because blur changed size of image)
        // https://stackoverflow.com/questions/20531938/cigaussianblur-image-size
        let filteredImage = UIImage(ciImage: filter.outputImage!.cropped(to: imageToFilter.extent))
        return filteredImage
    }
    
    public func motionBlurWithCoreImage(inputRadius: Float = 20.0, inputAngle: Float = 0.0) -> UIImage {
        // Filter the UIImage
        let imageToFilter = ciImage ?? CIImage(cgImage: cgImage!)
        let filter = CIFilter(name: "CIMotionBlur", withInputParameters: ["inputImage": imageToFilter,
                                                                          "inputRadius": inputRadius,
                                                                          "inputAngle": inputAngle])!
        
        // create UIImage from filtered image (adjust rect because blur changed size of image)
        // https://stackoverflow.com/questions/20531938/cigaussianblur-image-size
        let filteredImage = UIImage(ciImage: filter.outputImage!.cropped(to: imageToFilter.extent))
        return filteredImage
    }
    
    public func zoomBlurWithCoreImage(inputAmount: Float = 20.0, inputCenter: CGPoint = CGPoint(x: 150, y: 150)) -> UIImage {
        // Filter the UIImage
        let imageToFilter = ciImage ?? CIImage(cgImage: cgImage!)
        let filter = CIFilter(name: "CIZoomBlur", withInputParameters: ["inputImage": imageToFilter,
                                                                        "inputAmount": inputAmount,
                                                                        "inputCenter": CIVector(cgPoint: inputCenter)])!
        
        // create UIImage from filtered image (adjust rect because blur changed size of image)
        // https://stackoverflow.com/questions/20531938/cigaussianblur-image-size
        let filteredImage = UIImage(ciImage: filter.outputImage!.cropped(to: imageToFilter.extent))
        return filteredImage
    }
    
    public func boxBlurWithCoreImage(inputRadius: Float = 10.0) -> UIImage {
        // Filter the UIImage
        let imageToFilter = ciImage ?? CIImage(cgImage: cgImage!)
        let filter = CIFilter(name: "CIBoxBlur", withInputParameters: ["inputImage": imageToFilter,
                                                                       "inputRadius": inputRadius])!
        
        // create UIImage from filtered image (adjust rect because blur changed size of image)
        // https://stackoverflow.com/questions/20531938/cigaussianblur-image-size
        let filteredImage = UIImage(ciImage: filter.outputImage!.cropped(to: imageToFilter.extent))
        return filteredImage
    }
    
    public func discBlurWithCoreImage(inputRadius: Float = 8.0) -> UIImage {
        // Filter the UIImage
        let imageToFilter = ciImage ?? CIImage(cgImage: cgImage!)
        let filter = CIFilter(name: "CIDiscBlur", withInputParameters: ["inputImage": imageToFilter,
                                                                        "inputRadius": inputRadius])!
        
        // create UIImage from filtered image (adjust rect because blur changed size of image)
        // https://stackoverflow.com/questions/20531938/cigaussianblur-image-size
        let filteredImage = UIImage(ciImage: filter.outputImage!.cropped(to: imageToFilter.extent))
        return filteredImage
    }
}
