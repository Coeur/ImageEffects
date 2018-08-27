//
//  ViewController.swift
//  SwiftImageEffects
//
//  Created by coeur on 09/14/2017.
//  Copyright (c) 2017 coeur. All rights reserved.
//

import UIKit
import SwiftImageEffects

let samplesBundlePath = Bundle.main.path(forResource: "SwiftImageEffectsSamples", ofType: "bundle")!

class ViewController: UIViewController {
    
    let sampleImage = UIImage(named: "MaxPixel.freegreatpicture.com-Architecture-Skyscrapers-Shanghai-Skyline-673087.jpg", in: Bundle(path: samplesBundlePath), compatibleWith: nil)
    
    @IBOutlet weak var originImageView: UIImageView!
    @IBOutlet weak var effectImageView: UIImageView!
    @IBOutlet weak var effect2ImageView: UIImageView!
    
    @IBOutlet weak var redSlider: UISlider!
    @IBOutlet weak var greenSlider: UISlider!
    @IBOutlet weak var blueSlider: UISlider!
    @IBOutlet weak var alphaSlider: UISlider!
    @IBOutlet weak var radiusSlider: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let image = sampleImage {
            loadImage(image)
        }
    }
    
    func loadImage(_ image: UIImage) {
        originImageView.image = image
        let originImage = originImageView.renderImage()
        effectImageView.image = originImage.gaussianBlurWithCoreImage()
        effect2ImageView.image = originImage.appliedBlur(withRadius: 10, tintColor: nil, saturationDeltaFactor: 1, maskImage: nil)
    }
    
    @IBAction func selectImage(_ sender: Any) {
        presentImagePickerActionSheet()
    }
    
    @IBAction func sliderChanged(_ sender: Any) {
        // TODO: sliderChanged
        /*
         let red = redSlider.value
         let green = greenSlider.value
         let blue = blueSlider.value
         let alpha = alphaSlider.value
         let color = UIColor(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: CGFloat(alpha))
         let radius = radiusSlider.value
         */
    }
    
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            loadImage(image)
        }
    }
}
