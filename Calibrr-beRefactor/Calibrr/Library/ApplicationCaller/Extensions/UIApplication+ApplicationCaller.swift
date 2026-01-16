//
//  UIApplication+ApplicationCaller.swift
//  Appz
//
//
//  Copyright © kitz. All rights reserved.
//

import UIKit


extension UIApplication: ApplicationCaller {
    
    public func openURL(_ url: URL) -> Bool {
        // Check if we can open the URL first
        guard canOpenURL(url) else {
            return false
        }
        
        // Use the modern async open method without blocking the main thread
        // This prevents the app from freezing when returning from external apps
        open(url, options: [:]) { success in
            if !success {
                print("Failed to open URL: \(url)")
            }
        }
        
        // Return true immediately if we can open the URL
        // The actual opening happens asynchronously
        return true
    }
}
