//
//  DataUtils.swift
//  Calibrr
//
//
//  Copyright © Calibrr. All rights reserved.
//

import Foundation

extension Data
{
    func getTokenString() -> String
    {
        return self.reduce("", {$0 + String(format: "%02X", $1)})
    }
}
