//
//  Tracking.swift
//  Calibrr
//
//  Created by Kamil Chmurzynski on 10/06/2019.
//  Copyright © 2019 NCRTS. All rights reserved.
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
