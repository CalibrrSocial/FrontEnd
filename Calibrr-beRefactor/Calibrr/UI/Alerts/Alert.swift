//
//  Alert.swift
//  Calibrr
//
//
//  Copyright © Calibrr. All rights reserved.
//

import UIKit
import SnapKit

typealias CompletionHandlerClosureType = () -> ()
typealias CompletionAlertControllerHandler = (UIAlertController) -> ()

class Alert
{
    private static let pickerDelegate = ImagePickerDelegate()
    
    class func Basic(title: String = "Alert", message: String, actionTitle: String = "OK", from: UIViewController? = nil, completionHandler: CompletionHandlerClosureType? = nil)
    {
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let action = UIAlertAction(title: actionTitle, style: .default) { (action) in
            if let completionHandler = completionHandler {
                completionHandler()
            }
        }
        
        alertView.addAction(action)
        
        if let targetController = from ?? UIApplication.shared.keyWindow?.rootViewController {
            targetController.present(alertView, animated: true, completion: nil)
        }
    }
    
    class func Error(error: Error, from: UIViewController? = nil, completionHandler: CompletionHandlerClosureType? = nil)
    {
        if let error = error as? CBRError {
            Error(title: error.title ?? "Error", message: error.description, from: from, completionHandler: completionHandler)
        } else {
            Error(title: "Error", message: error.localizedDescription, from: from, completionHandler: completionHandler)
        }
    }
    
    class func Error(title: String = "Error", message: String, from: UIViewController? = nil, completionHandler: CompletionHandlerClosureType? = nil)
    {
        Basic(title: title, message: message, from: from, completionHandler: completionHandler)
    }
    
    class func Choice(title: String, message: String, actionTitle: String = "OK", actionDestructive: Bool = false, cancelTitle: String = "Cancel", cancelDestructive: Bool = false, from: UIViewController? = nil, completionHandler: @escaping CompletionHandlerClosureType, cancelHandler: CompletionHandlerClosureType? = nil)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: cancelTitle, style: cancelDestructive ? .destructive : .cancel) { a in cancelHandler?() })
        alert.addAction(UIAlertAction(title: actionTitle, style: actionDestructive ? .destructive : .default) { a in completionHandler() })
        
        if let targetController = from ?? UIApplication.shared.keyWindow?.rootViewController {
            targetController.present(alert, animated: true, completion: nil)
        }
    }
    
    class func PleaseWait(title: String, message: String = "Please wait...\n\n\n", from: UIViewController? = nil, cancelHandler: CompletionAlertControllerHandler? = nil, completionHandler: CompletionAlertControllerHandler? = nil)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if let cancelCompletionHandler = cancelHandler {
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { (action) in
                cancelCompletionHandler(alert)
            })
        }
        
        let activityIndicator = CBRActivityIndicatorView()
        activityIndicator.startAnimating()
        alert.view.addSubview(activityIndicator)
        
        activityIndicator.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(100)
            make.bottom.equalToSuperview().offset(-80)
        }
        
        if let targetController = from ?? UIApplication.shared.keyWindow?.rootViewController {
            targetController.present(alert, animated: true, completion: {
                if let completionHandler = completionHandler {
                    completionHandler(alert)
                }
            })
        }
    }
    
    class func SettingsAccessDeniedForced(subject: String, from: UIViewController)
    {
        Alert.Basic(title: "Access to \(subject) denied",
            message: "You have previously denied access to the \(subject). You must enable it in the Settings.",
            actionTitle: "Go to Settings",
            from: from,
            completionHandler: {
                DispatchQueue.main.async{
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                }
        })
    }
    
    class func SettingsAccessDenied(subject: String)
    {
        SettingsAccessDenied(title: "Access to \(subject) denied", message: "You have previously denied access to the \(subject). Please enable it in the Settings.")
    }
    
    class func SettingsAccessDenied(title: String, message: String)
    {
        Alert.Choice(title: title,
                     message: message,
                     actionTitle: "Go to Settings",
                     cancelTitle: "Cancel",
                     completionHandler: {
                        DispatchQueue.main.async{
                            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                        }
        })
    }
    
    class func PhotoSelection(from: UIViewController, title: String, message: String, barButtonItem: UIBarButtonItem, callback: @escaping ImagePickerCallback)
    {
        let alertController = PhotoSelection(from: from, title: title, message: message, callback: callback)
        alertController.popoverPresentationController?.barButtonItem = barButtonItem
    }
    
    class func PhotoSelection(from: UIViewController, title: String, message: String, sourceView: UIView, callback: @escaping ImagePickerCallback)
    {
        let alertController = PhotoSelection(from: from, title: title, message: message, callback: callback)
        alertController.popoverPresentationController?.sourceView = sourceView
        alertController.popoverPresentationController?.sourceRect = CGRect(x: sourceView.bounds.midX, y: sourceView.bounds.maxY, width: 0, height: 0)
        alertController.popoverPresentationController?.permittedArrowDirections = .up
    }
    
    private class func PhotoSelection(from: UIViewController, title: String, message: String, callback: @escaping ImagePickerCallback) -> UIAlertController
    {
        pickerDelegate.pickedImageCallback = callback
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let takePhotoAction = UIAlertAction(title: "Take Photo", style:.default) { (action) in
                DevicePermissionService.singleton.requestVideoPermission(callback: { success in
                    if success {
                        let imagePicker = UIImagePickerController()
                        imagePicker.delegate = pickerDelegate
                        imagePicker.allowsEditing = false
                        imagePicker.sourceType = .camera
                        imagePicker.cameraCaptureMode = .photo
                        imagePicker.modalPresentationStyle = .fullScreen
                        from.present(imagePicker, animated: true)
                    }else{
                        SettingsAccessDenied(subject: "Camera")
                    }
                })
            }
            alertController.addAction(takePhotoAction)
        }
        
        let selectPhotoAction = UIAlertAction(title: "Photo Album", style:.default) { (action) in
            DevicePermissionService.singleton.requestPhotoPermission(callback: { success in
                if success {
                    let imagePicker = UIImagePickerController()
                    imagePicker.delegate = pickerDelegate
                    imagePicker.allowsEditing = false
                    imagePicker.sourceType = .photoLibrary
                    imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
                    from.present(imagePicker, animated: true)
                }else{
                    SettingsAccessDenied(subject: "Photos")
                }
            })
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style:.cancel) { (action) in
            alertController.dismiss(animated: true)
        }
        
        alertController.addAction(selectPhotoAction)
        alertController.addAction(cancelAction)
        
        from.present(alertController, animated: true)
        
        return alertController
    }
}
