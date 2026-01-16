//
//  BugTracking.swift
//  Calibrr
//
//
//  Copyright © Calibrr. All rights reserved.
//

//import Bugsnag

class BugTracking
{
    class func Initialise()
    {
//      Bugsnag.start(withApiKey: "")
    }
    
    class func SetupUser(_ email: String)
    {
//        Bugsnag.addAttribute("userEmail", withValue: email, toTabWithName: "user")
    }
    
    class func Track(_ error: Error)
    {
//        Bugsnag.notifyError(error)
    }
}
