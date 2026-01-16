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
        
        // Add a small delay to ensure the app has fully transitioned to foreground
        // This prevents UI freezing when returning from external apps
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            if let nav = self.window?.rootViewController as? CBRNavigator {
                // Check moderation status when app comes to foreground
                if ActiveUser.singleton.loggedIn {
                    ActiveUser.singleton.checkModerationStatus(nav) { isAllowed in
                        if isAllowed {
                            // Only reload data if the current view controller is not a profile page
                            // Profile pages handle their own lifecycle updates
                            if let topVC = nav.topViewController,
                               !(topVC is ProfilePage) && !(topVC is ProfileFriendPage) {
                                (topVC as? IPage)?.reloadData()
                            }
                        }
                        // If not allowed, the moderation screen is already shown
                    }
                } else {
                    // Only reload data if the current view controller is not a profile page
                    if let topVC = nav.topViewController,
                       !(topVC is ProfilePage) && !(topVC is ProfileFriendPage) {
                        (topVC as? IPage)?.reloadData()
                    }
                }
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

