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
// Swift 3 compatibility
extension CIImage {
    /* Return a new image cropped to a rectangle. */
    func cropped(to rect: CGRect) -> CIImage {
        return cropping(to: rect)
    }
}
#endif
#if swift(>=4.2)
#else
// Swift 4.0 compatibility
extension CIFilter {
    /** Creates a new filter of type 'name'.
     The filter's input parameters are set from the dictionary of key-value pairs.
     On OSX, any of the filter input parameters not specified in the dictionary will be undefined.
     On iOS, any of the filter input parameters not specified in the dictionary will be set to default values. */
    convenience init?(name: String, parameters params: [String: Any]?) {
        self.init(name: name, withInputParameters: params)
    }
}
#endif

// https://developer.apple.com/library/content/documentation/GraphicsImaging/Reference/CoreImageFilterReference/
extension UIImage {
    
    public func gaussianBlurWithCoreImage(inputRadius: Float = 10.0) -> UIImage {
        // Filter the UIImage
        let imageToFilter = ciImage ?? CIImage(cgImage: cgImage!)
        let filter = CIFilter(name: "CIGaussianBlur", parameters: ["inputImage": imageToFilter,
                                                                   "inputRadius": inputRadius])!
        
        // create UIImage from filtered image (adjust rect because blur changed size of image)
        // https://stackoverflow.com/questions/20531938/cigaussianblur-image-size
        let filteredImage = UIImage(ciImage: filter.outputImage!.cropped(to: imageToFilter.extent))
        return filteredImage
    }
    
    public func motionBlurWithCoreImage(inputRadius: Float = 20.0, inputAngle: Float = 0.0) -> UIImage {
        // Filter the UIImage
        let imageToFilter = ciImage ?? CIImage(cgImage: cgImage!)
        let filter = CIFilter(name: "CIMotionBlur", parameters: ["inputImage": imageToFilter,
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
        let filter = CIFilter(name: "CIZoomBlur", parameters: ["inputImage": imageToFilter,
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
        let filter = CIFilter(name: "CIBoxBlur", parameters: ["inputImage": imageToFilter,
                                                              "inputRadius": inputRadius])!
        
        // create UIImage from filtered image (adjust rect because blur changed size of image)
        // https://stackoverflow.com/questions/20531938/cigaussianblur-image-size
        let filteredImage = UIImage(ciImage: filter.outputImage!.cropped(to: imageToFilter.extent))
        return filteredImage
    }
    
    public func discBlurWithCoreImage(inputRadius: Float = 8.0) -> UIImage {
        // Filter the UIImage
        let imageToFilter = ciImage ?? CIImage(cgImage: cgImage!)
        let filter = CIFilter(name: "CIDiscBlur", parameters: ["inputImage": imageToFilter,
                                                               "inputRadius": inputRadius])!
        
        // create UIImage from filtered image (adjust rect because blur changed size of image)
        // https://stackoverflow.com/questions/20531938/cigaussianblur-image-size
        let filteredImage = UIImage(ciImage: filter.outputImage!.cropped(to: imageToFilter.extent))
        return filteredImage
    }
}
