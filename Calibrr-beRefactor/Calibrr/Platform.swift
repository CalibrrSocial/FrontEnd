//
//  Platform.swift
//  Calibrr
//
//
//  Copyright © Calibrr. All rights reserved.
//

import Foundation

struct Platform
{
    static var isSimulator : Bool
    {
        return TARGET_OS_SIMULATOR != 0
    }
    
    static var isDev : Bool
    {
        return true
    }
}
