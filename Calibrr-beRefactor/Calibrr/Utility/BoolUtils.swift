//
//  BoolUtils.swift
//  Calibrr
//
//
//  Copyright © Calibrr. All rights reserved.
//

import Foundation

infix operator &&&: LogicalConjunctionPrecedence

func &&& (lhs: Bool, rhs: Bool) -> Bool {
    return [lhs, rhs].allSatisfy {$0 == true}
}
