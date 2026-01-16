//
//  ArrayUtils.swift
//  Calibrr
//
//  Created by Kamil Chmurzynski on 03/06/2019.
//  Copyright © 2019 NCRTS. All rights reserved.
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
