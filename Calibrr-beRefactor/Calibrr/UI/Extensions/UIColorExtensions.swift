//
//  UIColorExtensions.swift
//  Calibrr
//
//
//  Copyright © Calibrr. All rights reserved.
//

import UIKit

extension UIColor
{
    static let cbrBlue = fromRGB(red: 42.0, green: 179.0, blue: 226.0)
    
    static let cbrGreen = fromRGB(red: 0.0, green: 230.0, blue: 159.0)
    
    static let cbrRed = fromRGB(red: 255.0, green: 59.0, blue: 94.0)
    
    static let cbrRedTransparent = cbrRed.makeTransparent(alpha: 0.5)
    
    static let cbrGray = UIColor(white: 180.0 / 255.0, alpha: 1.0)
    
    static let cbrGrayTransparent = cbrGray.makeTransparent(alpha: 0.5)
    
    static let cbrGrayLight = UIColor(white: 230.0 / 255.0, alpha: 1.0)
    
    static let cbrGrayLightTransparent = cbrGrayLight.makeTransparent(alpha: 0.5)
    
    private class func fromRGB(red: Float, green: Float, blue: Float, alpha: Float = 1.0) -> UIColor
    {
        return UIColor(displayP3Red: CGFloat(red/255.0), green: CGFloat(green/255.0), blue: CGFloat( blue/255.0), alpha: CGFloat(alpha))
    }
    
    func makeTransparent(alpha: CGFloat) -> UIColor
    {
        var red : CGFloat = 0
        var green : CGFloat = 0
        var blue : CGFloat = 0
        var alphaDiscard : CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alphaDiscard)
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}
