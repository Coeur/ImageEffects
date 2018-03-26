//
//  ImageEffects+Accelerate.swift
//  Pods
//
//  Created by Antoine Cœur on 07/08/2017.
//
//

/*
 Abstract: This class contains methods to apply blur and tint effects to an image.
 This is the code you’ll want to look out to find out how to use vImage to efficiently calculate a blur.
 Version: 1.1.Coeur
 
 Swift implementation of https://developer.apple.com/library/content/samplecode/UIImageEffects/
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 */

import UIKit
import Accelerate

extension UIImage {
    
    // MARK: - Effects
    
    public func appliedLightEffect() -> UIImage? {
        let tintColor = UIColor(white: 1.0, alpha: 0.3)
        return appliedBlur(withRadius: 60, tintColor: tintColor, saturationDeltaFactor: 1.8, maskImage: nil)
    }
    
    public func appliedExtraLightEffect() -> UIImage? {
        let tintColor = UIColor(white: 0.97, alpha: 0.82)
        return appliedBlur(withRadius: 40, tintColor: tintColor, saturationDeltaFactor: 1.8, maskImage: nil)
    }
    
    public func appliedDarkEffect() -> UIImage? {
        let tintColor = UIColor(white: 0.11, alpha: 0.73)
        return appliedBlur(withRadius: 40, tintColor: tintColor, saturationDeltaFactor: 1.8, maskImage: nil)
    }
    
    public func appliedTintEffectWithColor(tintColor: UIColor) -> UIImage? {
        let effectColorAlpha: CGFloat = 0.6
        var effectColor = tintColor
        if tintColor.cgColor.numberOfComponents == 2 {
            var b: CGFloat = 0
            if tintColor.getWhite(&b, alpha: nil) {
                effectColor = UIColor(white: b, alpha: effectColorAlpha)
            }
        } else {
            var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0
            if tintColor.getRed(&r, green: &g, blue: &b, alpha: nil) {
                effectColor = UIColor(red: r, green: g, blue: b, alpha: effectColorAlpha)
            }
        }
        return appliedBlur(withRadius: 20, tintColor: effectColor, saturationDeltaFactor: -1.0, maskImage: nil)
    }
    
    // MARK: - Implementation
    
    /// Applies a blur, tint color, and saturation adjustment to inputImage,
    /// optionally within the area specified by @a maskImage.
    ///
    /// - Parameter blurRadius:
    ///         The radius of the blur in points.
    /// - Parameter tintColor:
    ///         An optional UIColor object that is uniformly blended with the result of the blur and saturation operations.
    ///         The alpha channel of this color determines how strong the tint is.
    /// - Parameter saturationDeltaFactor:
    ///         A value of 1.0 produces no change in the resulting image.
    ///         Values less than 1.0 will desaturation the resulting image
    ///         while values greater than 1.0 will have the opposite effect.
    /// - Parameter maskImage:
    ///         If specified, inputImage is only modified in the area(s) defined by this mask.
    ///         This must be an image mask or it must meet the requirements of the mask parameter of CGContextClipToMask.
    public func appliedBlur(withRadius blurRadius: CGFloat, tintColor: UIColor? = nil, saturationDeltaFactor: CGFloat = 1.0, maskImage: UIImage? = nil) -> UIImage? {
        // Check pre-conditions.
        if size.width < 1 || size.height < 1 {
            NSLog("*** error: invalid size: (%.2f x %.2f). Both dimensions must be >= 1: %@", size.width, size.height, self)
            return nil
        }
        guard let inputCGImage = cgImage else {
            NSLog("*** error: inputImage must be backed by a CGImage: %@", self)
            return nil
        }
        if let maskImage = maskImage, maskImage.cgImage == nil {
            NSLog("*** error: effectMaskImage must be backed by a CGImage: %@", maskImage)
            return nil
        }
        
        let hasBlur = blurRadius > .ulpOfOne
        let hasSaturationChange = fabs(saturationDeltaFactor - 1.0) > .ulpOfOne
        
        let inputImageScale = scale
        let inputImageAlphaInfo = CGImageAlphaInfo(rawValue: inputCGImage.bitmapInfo.rawValue & CGBitmapInfo.alphaInfoMask.rawValue)
        
        let outputImageSizeInPoints = size
        let outputImageRectInPoints = CGRect(origin: .zero, size: outputImageSizeInPoints)
        
        // Set up output context.
        let useOpaqueContext = inputImageAlphaInfo == .none || inputImageAlphaInfo == .noneSkipLast || inputImageAlphaInfo == .noneSkipFirst
        UIGraphicsBeginImageContextWithOptions(outputImageRectInPoints.size, useOpaqueContext, inputImageScale)
        defer { UIGraphicsEndImageContext() }
        let outputContext = UIGraphicsGetCurrentContext()!
        outputContext.scaleBy(x: 1.0, y: -1.0)
        outputContext.translateBy(x: 0, y: -outputImageRectInPoints.size.height)
        
        if hasBlur || hasSaturationChange {
            // requests a BGRA buffer.
            let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue)
            var format = vImage_CGImageFormat(bitsPerComponent: 8,
                                              bitsPerPixel: 32,
                                              colorSpace: nil,
                                              bitmapInfo: bitmapInfo,
                                              version: 0,
                                              decode: nil,
                                              renderingIntent: CGColorRenderingIntent.defaultIntent)
            
            var inputBuffer = vImage_Buffer()
            var outputBuffer = vImage_Buffer()
            
            let e: vImage_Error = vImageBuffer_InitWithCGImage(&inputBuffer, &format, nil, inputCGImage, vImage_Flags(kvImagePrintDiagnosticsToConsole))
            if e != kvImageNoError {
                NSLog("*** error: vImageBuffer_InitWithCGImage returned error code %zi for inputImage: %@", e, self)
                return nil
            }
            
            vImageBuffer_Init(&outputBuffer, inputBuffer.height, inputBuffer.width, format.bitsPerPixel, vImage_Flags(kvImageNoFlags))
            
            if hasBlur {
                // A description of how to compute the box kernel width from the Gaussian
                // radius (aka standard deviation) appears in the SVG spec:
                // http://www.w3.org/TR/SVG/filters.html#feGaussianBlurElement
                //
                // For larger values of 's' (s >= 2.0), an approximation can be used: Three
                // successive box-blurs build a piece-wise quadratic convolution kernel, which
                // approximates the Gaussian kernel to within roughly 3%.
                //
                // let d = floor(s * 3*sqrt(2*pi)/4 + 0.5)
                //
                // ... if d is odd, use three box-blurs of size 'd', centered on the output pixel.
                //
                var inputRadius = blurRadius * inputImageScale
                if inputRadius - 2.0 < .ulpOfOne {
                    inputRadius = 2.0
                }
                
                var radius = UInt32(floor((inputRadius * 3.0 * sqrt(2 * .pi) / 4 + 0.5) / 2) as CGFloat)
                
                radius |= 1 // force radius to be odd so that the three box-blur methodology works.
                
                let tempBufferSize = vImageBoxConvolve_ARGB8888(&inputBuffer, &outputBuffer, nil, 0, 0, radius, radius, nil, vImage_Flags(kvImageGetTempBufferSize | kvImageEdgeExtend))
                let tempBuffer = malloc(tempBufferSize)
                
                vImageBoxConvolve_ARGB8888(&inputBuffer, &outputBuffer, tempBuffer, 0, 0, radius, radius, nil, vImage_Flags(kvImageEdgeExtend))
                vImageBoxConvolve_ARGB8888(&outputBuffer, &inputBuffer, tempBuffer, 0, 0, radius, radius, nil, vImage_Flags(kvImageEdgeExtend))
                vImageBoxConvolve_ARGB8888(&inputBuffer, &outputBuffer, tempBuffer, 0, 0, radius, radius, nil, vImage_Flags(kvImageEdgeExtend))
                
                free(tempBuffer)
                
                let temp = inputBuffer
                inputBuffer = outputBuffer
                outputBuffer = temp
            }
            
            if hasSaturationChange {
                let s = saturationDeltaFactor
                // These values from Apple appear in the W3C Filter Effects spec:
                // https://www.w3.org/TR/filter-effects-1/#grayscaleEquivalent
                //
                let floatingPointSaturationMatrix: [CGFloat] = [
                    0.072_2 + 0.927_8 * s,  0.072_2 - 0.072_2 * s,  0.072_2 - 0.072_2 * s,  0,
                    0.715_2 - 0.715_2 * s,  0.715_2 + 0.284_8 * s,  0.715_2 - 0.715_2 * s,  0,
                    0.212_6 - 0.212_6 * s,  0.212_6 - 0.212_6 * s,  0.212_6 + 0.787_3 * s,  0,
                    0,                      0,                      0,                      1,
                    ]
                let divisor: CGFloat = 256
                let saturationMatrix: [Int16] = floatingPointSaturationMatrix.map { Int16(roundf(Float($0 * divisor))) }
                vImageMatrixMultiply_ARGB8888(&inputBuffer, &outputBuffer, saturationMatrix, Int32(divisor), nil, nil, vImage_Flags(kvImageNoFlags))
                
                let temp = inputBuffer
                inputBuffer = outputBuffer
                outputBuffer = temp
            }
            
            ///  Helper function to handle deferred cleanup of a buffer.
            func cleanupBuffer(_ userData: UnsafeMutableRawPointer?, _ bufData: UnsafeMutableRawPointer?) {
                free(bufData)
            }
            
            var effectCGImage = vImageCreateCGImageFromBuffer(&inputBuffer, &format, cleanupBuffer, nil, vImage_Flags(kvImageNoAllocate), nil)?.takeRetainedValue()
            if effectCGImage == nil {
                effectCGImage = vImageCreateCGImageFromBuffer(&inputBuffer, &format, nil, nil, vImage_Flags(kvImageNoFlags), nil)!.takeRetainedValue()
                free(inputBuffer.data)
            }
            if maskImage != nil {
                // Only need to draw the base image if the effect image will be masked.
                outputContext.draw(inputCGImage, in: outputImageRectInPoints)
            }
            
            // draw effect image
            outputContext.saveGState()
            if let maskImage = maskImage {
                outputContext.clip(to: outputImageRectInPoints, mask: maskImage.cgImage!)
            }
            outputContext.draw(effectCGImage!, in: outputImageRectInPoints)
            outputContext.restoreGState()
            
            // Cleanup
            free(outputBuffer.data)
        } else {
            // draw base image
            outputContext.draw(inputCGImage, in: outputImageRectInPoints)
        }
        
        // Add in color tint.
        if let tintColor = tintColor {
            outputContext.saveGState()
            outputContext.setFillColor(tintColor.cgColor)
            outputContext.fill(outputImageRectInPoints)
            outputContext.restoreGState()
        }
        
        // Output image is ready.
        let outputImage = UIGraphicsGetImageFromCurrentImageContext()
        return outputImage
    }
}
