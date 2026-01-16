//
//  UIImageViewExtensions.swift
//  Calibrr
//
//
//  Copyright © Calibrr. All rights reserved.
//

import UIKit

extension UIImageView
{
    @discardableResult
    @objc override func roundFull() -> UIView
    {
        super.roundFull()
        contentMode = .scaleAspectFill
        
        return self
    }
}
