//
//  ArrayUtils.swift
//  Calibrr
//
//
//  Copyright © Calibrr. All rights reserved.
//

import Foundation

extension Array where Element : Collection
{
    func deepCount() -> Int
    {
        var itemCount = 0
        for i in 0..<count {
            itemCount += self[i].count
        }
        return itemCount
    }
}
