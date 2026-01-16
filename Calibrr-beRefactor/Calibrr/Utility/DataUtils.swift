//
//  DataUtils.swift
//  Calibrr
//
//  Created by Kamil Chmurzynski on 03/06/2019.
//  Copyright © 2019 NCRTS. All rights reserved.
//

import Foundation

extension Data
{
    func getTokenString() -> String
    {
        return self.reduce("", {$0 + String(format: "%02X", $1)})
    }
}
