//
//  CBRProgressBarButtonItem.swift
//  Calibrr
//
//
//  Copyright © Calibrr. All rights reserved.
//

import UIKit

class CBRProgressBarButtonItem : UIBarButtonItem
{
    let indicator = CBRActivityIndicatorView(frame: CGRect(x: 10, y: 10, width: 20, height: 20), indicatorColour: UIColor.white)
    
    override init()
    {
        super.init()
        
        indicator.startAnimating()
        
        customView = indicator
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
}
