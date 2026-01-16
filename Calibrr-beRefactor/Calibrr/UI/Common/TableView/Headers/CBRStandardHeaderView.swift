//
//  CBRStandardHeaderView.swift
//  Calibrr
//
//  Created by Kamil Chmurzynski on 19/06/2019.
//  Copyright © 2019 Calibrr. All rights reserved.
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
