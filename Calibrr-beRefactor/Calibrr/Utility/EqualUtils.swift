//
//  EqualUtils.swift
//  Calibrr
//
//
//  Copyright © Calibrr. All rights reserved.
//

import Foundation

func ==(lhs: [String : Any], rhs: [String : Any]) -> Bool {
    return NSDictionary(dictionary: lhs).isEqual(to: rhs)
}
func !=(lhs: [String : Any], rhs: [String : Any]) -> Bool {
    return !(lhs == rhs)
}

func ==(lhs: [Any], rhs: [Any]) -> Bool {
    return NSArray(array: lhs).isEqual(to: rhs)
}
func !=(lhs: [Any], rhs: [Any]) -> Bool {
    return !(lhs == rhs)
}
