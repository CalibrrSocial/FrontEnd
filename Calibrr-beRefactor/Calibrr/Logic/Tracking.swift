//
//  Tracking.swift
//  Calibrr
//
//
//  Copyright © Calibrr. All rights reserved.
//

import Foundation

class Tracking
{
    class func Initialise()
    {
    }
    
    class func SetupUser(_ email: String)
    {
        //        Mixpanel.mainInstance().identify(distinctId: email)
    }
    
    class func TrackEnterForeground()
    {
        Track("enterForeground")
    }
    
    class func Track(_ event: String, parameters: [String : Any] = [:])
    {
        //        let properties = parameters as? Properties
        //
        //        Mixpanel.mainInstance().track(event: event, properties: properties)
    }
}
