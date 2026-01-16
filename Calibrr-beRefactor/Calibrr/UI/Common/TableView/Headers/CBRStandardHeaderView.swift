//
//  CBRStandardHeaderView.swift
//  Calibrr
//
//
//  Copyright © Calibrr. All rights reserved.
//

import UIKit

class CBRStandardHeaderView : UIView
{
    @IBOutlet weak var label : UILabel!
    
    func setup(_ text: String, backgroundColour: UIColor = UIColor.clear)
    {
        backgroundColor = backgroundColour
        label.text = text
    }
}
