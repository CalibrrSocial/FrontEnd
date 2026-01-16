//
//  UIApplication+ApplicationCaller.swift
//  Appz
//
//  Created by Mazyad Alabduljaleel on 11/9/15.
//  Copyright © 2015 kitz. All rights reserved.
//

import UIKit


extension UIApplication: ApplicationCaller {
    
    public func openURL(_ url: URL) -> Bool {
        // Use the modern open method instead of deprecated openURL
        var success = false
        let semaphore = DispatchSemaphore(value: 0)
        
        open(url, options: [:]) { (result) in
            success = result
            semaphore.signal()
        }
        
        // Wait for the completion handler to be called
        _ = semaphore.wait(timeout: .distantFuture)
        return success
    }
}
