//
//  UITextFieldExtensions.swift
//  Calibrr
//
//  Created by Kamil Chmurzynski on 11/06/2019.
//  Copyright © 2019 Calibrr. All rights reserved.
//

import UIKit

extension UITextField
{
    func setupDark(textSize: CGFloat, bold: Bool = false)
    {
        font = bold ? UIFont.boldSystemFont(ofSize: textSize) : UIFont.systemFont(ofSize: textSize)
        textColor = UIColor(hexString: "#282828")
        backgroundColor = .clear
    }
    
    func setupWhite(textSize: CGFloat, bold: Bool = false)
    {
        font = bold ? UIFont.boldSystemFont(ofSize: textSize) : UIFont.systemFont(ofSize: textSize)
        textColor = UIColor.white
        backgroundColor = .clear
    }
    
    func setupMainDark(textSize: CGFloat, bold: Bool = false)
    {
        font = bold ? UIFont.boldSystemFont(ofSize: textSize) : UIFont.systemFont(ofSize: textSize)
        textColor = UIColor(hexString: "#413F3F")
        backgroundColor = .clear
    }
    
    func setLeftPaddingPoints(_ amount:CGFloat)
    {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: frame.size.height))
        leftView = paddingView
        leftViewMode = .always
    }
}

extension UITextView {
    func scrollToBottom() {
        if self.text.count > 0 {
            let location = self.text.count - 1
            let bottom = NSMakeRange(location, 1)
            self.scrollRangeToVisible(bottom)
        }
    }
}
