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
        
        IQKeyboardManager.shared.toolbarConfiguration.previousNextDisplayMode = .default
        IQKeyboardManager.shared.toolbarConfiguration.placeholderConfiguration.showPlaceholder = false
        
        showNavigationController()
        
        Tracking.Track("launch")
        
        return true
    }
    
    func applicationWillEnterForeground(_ application: UIApplication)
    {
        Tracking.TrackEnterForeground()
        
        if let nav = window?.rootViewController as? CBRNavigator {
            (nav.topViewController as? IPage)?.reloadData()
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

