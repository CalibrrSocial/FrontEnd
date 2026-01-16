//
//  DevicePermissionService.swift
//  Calibrr
//
//
//  Copyright © Calibrr. All rights reserved.
//

import Photos
import UserNotifications
import UIKit

class DevicePermissionService
{
    static let singleton = DevicePermissionService()
    
    func hasAllVideoCallPermissions(callback: @escaping (Bool) -> ())
    {
        if getVideoPermission() {
            getPushNotificationPermission(callback: callback)
        }else{
            callback(false)
        }
    }
    
    func requestPushNotificationPermission(callback: @escaping (Bool) -> ())
    {
        UNUserNotificationCenter.current().requestAuthorization(options:[.badge, .alert, .sound]) { (granted, error) in
            DispatchQueue.main.async {
                if granted {
                    UIApplication.shared.registerForRemoteNotifications()
                    callback(true)
                }else{
                    error?.createCBR().logAndPresent()
                    callback(false)
                }
            }
        }
    }
    
    func getPushNotificationPermission(callback: @escaping (Bool) -> ())
    {
        UNUserNotificationCenter.current().getNotificationSettings(completionHandler: { (settings) in
            callback(settings.authorizationStatus == .authorized)
        })
    }
    
    func requestPhotoPermission(callback: @escaping (Bool) -> ())
    {
        PHPhotoLibrary.requestAuthorization { (status) in
            DispatchQueue.main.sync {
                callback(status == PHAuthorizationStatus.authorized)
            }
        }
    }
    
    func getVideoPermission() -> Bool
    {
        return AVCaptureDevice.authorizationStatus(for: .video) == .authorized
    }
    
    func requestVideoPermission(callback: @escaping (Bool) -> ())
    {
        AVCaptureDevice.requestAccess(for: .video) { response in
            DispatchQueue.main.sync {
                callback(response)
            }
        }
    }
    
    func getMicPermission() -> Bool
    {
        return AVAudioSession.sharedInstance().recordPermission == .granted
    }
    
    func requestMicPermission(callback: @escaping (Bool) -> ())
    {
        AVAudioSession.sharedInstance().requestRecordPermission { (response) in
            DispatchQueue.main.async {
                callback(response)
            }
        }
    }
}
