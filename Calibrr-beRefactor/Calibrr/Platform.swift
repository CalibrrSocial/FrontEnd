//
//  Platform.swift
//  Calibrr
//
//  Created by Kamil Chmurzynski on 10/06/2019.
//  Copyright © 2019 NCRTS. All rights reserved.
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
