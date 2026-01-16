//
//  BoolUtils.swift
//  Calibrr
//
//  Created by Kamil Chmurzynski on 03/06/2019.
//  Copyright © 2019 NCRTS. All rights reserved.
//

import Foundation

infix operator &&&: LogicalConjunctionPrecedence

func &&& (lhs: Bool, rhs: Bool) -> Bool {
    return [lhs, rhs].allSatisfy {$0 == true}
}
