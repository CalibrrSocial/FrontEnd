//
//  UILabelExtensions.swift
//  Calibrr
//
//
//  Copyright © Calibrr. All rights reserved.
//

import UIKit

extension UILabel
{
    func setupWhite(textSize: CGFloat, bold: Bool = false)
    {
        font = bold ? UIFont.boldSystemFont(ofSize: textSize) : UIFont.systemFont(ofSize: textSize)
        textColor = UIColor.white
        numberOfLines = 0
    }
    
    func setupDark(textSize: CGFloat, bold: Bool = false)
    {
        font = bold ? UIFont.boldSystemFont(ofSize: textSize) : UIFont.systemFont(ofSize: textSize)
        textColor = UIColor(hexString: "#555555")
        backgroundColor = .clear
        numberOfLines = 0
    }
    
    func setupMainDark(textSize: CGFloat, bold: Bool = false)
    {
        font = bold ? UIFont.boldSystemFont(ofSize: textSize) : UIFont.systemFont(ofSize: textSize)
        textColor = UIColor(hexString: "#413F3F")
        backgroundColor = .clear
        numberOfLines = 0
    }
    
    func setupGray(textSize: CGFloat, bold: Bool = false)
    {
        font = bold ? UIFont.boldSystemFont(ofSize: textSize) : UIFont.systemFont(ofSize: textSize)
        textColor = UIColor.cbrGray
        backgroundColor = .clear
        numberOfLines = 0
    }
    
    func setupRed(textSize: CGFloat, bold: Bool = false)
    {
        font = bold ? UIFont.boldSystemFont(ofSize: textSize) : UIFont.systemFont(ofSize: textSize)
        textColor = UIColor.red
        backgroundColor = .clear
        numberOfLines = 0
    }
    
    func setupRedLight(textSize: CGFloat, bold: Bool = false)
    {
        font = bold ? UIFont.boldSystemFont(ofSize: textSize) : UIFont.systemFont(ofSize: textSize)
        textColor = UIColor.red
        backgroundColor = .clear
        numberOfLines = 0
    }
    
    func setupBlue(textSize: CGFloat, bold: Bool = false)
    {
        font = bold ? UIFont.boldSystemFont(ofSize: textSize) : UIFont.systemFont(ofSize: textSize)
        textColor = UIColor.cbrBlue
        backgroundColor = .clear
        numberOfLines = 0
    }
}

extension UILabel {
    func underlineMyText(range:String) {
        if let textString = self.text {
            let str = NSString(string: textString)
            let firstRange = str.range(of: range)
            let attributedString = NSMutableAttributedString(string: textString)
            attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: firstRange)
            attributedText = attributedString
        }
    }
}
