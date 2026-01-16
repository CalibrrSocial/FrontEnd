//
//  AppDelegate.swift
//  Calibrr
//
//  Created by Kamil Chmurzynski on 10/06/2019.
//  Copyright © 2019 NCRTS. All rights reserved.
//

import UserNotifications
import UIKit
import IQKeyboardManagerSwift
import OpenAPIClient

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{
    var window : UIWindow?
    
    class var shared : AppDelegate
    {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    {
        BugTracking.Initialise()
        Tracking.Initialise()
        
        OpenAPIClientAPI.basePath = APIKeys.BASE_API_URL
        
        IQKeyboardManager.shared.isEnabled = true
        IQKeyboardManager.shared.toolbarConfiguration.previousNextDisplayMode = .default
        IQKeyboardManager.shared.toolbarConfiguration.placeholderConfiguration.showPlaceholder = false
        IQKeyboardManager.shared.resignOnTouchOutside = false
        IQKeyboardManager.shared.enableAutoToolbar = true
        
        showNavigationController()
        
        Tracking.Track("launch")
        
        return true
    }
    
    func applicationWillEnterForeground(_ application: UIApplication)
    {
        Tracking.TrackEnterForeground()
        
        if let nav = window?.rootViewController as? CBRNavigator {
            // Check moderation status when app comes to foreground
            if ActiveUser.singleton.loggedIn {
                ActiveUser.singleton.checkModerationStatus(nav) { isAllowed in
                    if isAllowed {
                        (nav.topViewController as? IPage)?.reloadData()
                    }
                    // If not allowed, the moderation screen is already shown
                }
            } else {
                (nav.topViewController as? IPage)?.reloadData()
            }
        }
    }
    
    func applicationDidEnterBackground(_ application: UIApplication)
    {
        Tracking.Track("background")
        if !UserData.singleton.wasLoggedIn() {
            Tracking.Track("backgroundNotLoggedIn")
        }
    }
    
    private func showNavigationController()
    {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = CBRNavigator()
        window?.makeKeyAndVisible()
    }
}

