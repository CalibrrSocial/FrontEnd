//
//  UIImageViewExtensions.swift
//  Calibrr
//
//  Created by Kamil Chmurzynski on 18/06/2019.
//  Copyright © 2019 Calibrr. All rights reserved.
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
