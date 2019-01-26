//
//  ImagePicker.swift
//  SwiftImageEffects
//
//  Created by Antoine Cœur on 2018/8/27.
//  Copyright © 2018 Antoine Cœur. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

#if swift(>=4.2)
#else
// Swift 4.0 compatibility
extension UIImagePickerController {
    typealias SourceType = UIImagePickerControllerSourceType
}
extension UIApplication {
    static let openSettingsURLString = UIApplicationOpenSettingsURLString
}
#endif

extension UIImagePickerControllerDelegate where Self : UIViewController, Self : UINavigationControllerDelegate {
    /// Prompt the source choice for image picker
    func presentImagePickerActionSheet() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraAction = UIAlertAction(title: "Camera", style: .default) { [weak self] alert in
                self?.pickImage(sourceType: .camera)
            }
            alertController.addAction(cameraAction)
        }
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let selectFromAlbumAction = UIAlertAction(title: "Photo album", style: .default) { [weak self] alert in
                self?.pickImage(sourceType: .photoLibrary)
            }
            alertController.addAction(selectFromAlbumAction)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    /// Prompt the image picker
    private func pickImage(sourceType: UIImagePickerController.SourceType) {
        if sourceType == .camera {
            let authorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
            if authorizationStatus == .denied {
                // Prompt the user about permissions
                showImagePickerPermissionErrorAlert(sourceType: sourceType)
                return
            } else if authorizationStatus == .notDetermined {
                // Prompt the user about permissions before opening camera
                AVCaptureDevice.requestAccess(for: .video) { [weak self] success in
                    if success {
                        self?.pickImage(sourceType: sourceType)
                    }
                }
                return
            }
        } else {
            let authorizationStatus = PHPhotoLibrary.authorizationStatus()
            if authorizationStatus == .denied {
                // Prompt the user about permissions
                showImagePickerPermissionErrorAlert(sourceType: sourceType)
                return
            } else if authorizationStatus == .notDetermined {
                // Prompt the user about permissions before opening photo album
                if #available(iOS 11.0, *) {
                    // nothing to do: no permission request needed on iOS 11+
                } else {
                    PHPhotoLibrary.requestAuthorization { [weak self] success in
                        if success == .authorized {
                            self?.pickImage(sourceType: sourceType)
                        }
                    }
                    return
                }
            }
        }
        let mediaPicker = UIImagePickerController()
        mediaPicker.sourceType = sourceType
        if sourceType == .camera {
            mediaPicker.cameraCaptureMode = .photo
        }
        mediaPicker.allowsEditing = true
        mediaPicker.delegate = self
        present(mediaPicker, animated: true, completion: nil)
    }
    
    /// Prompt the user about permissions
    private func showImagePickerPermissionErrorAlert(sourceType: UIImagePickerController.SourceType) {
        let title: String
        if sourceType == .camera {
            title = "You didn't grant camera permission."
        } else {
            title = "You didn't grant photo album permission."
        }
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        
        // User has explicitly denied authorization for this application.
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { _ in
            UIApplication.shared.openURL(URL(string: UIApplication.openSettingsURLString)!)
        }
        alert.addAction(settingsAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
}
