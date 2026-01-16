//
//  BaseCell.swift
//  Calibrr
//
//  Created by Kamil Chmurzynski on 19/06/2019.
//  Copyright © 2019 Calibrr. All rights reserved.
//

import UIKit

class BaseCell : ACell<(String, String)>
{
    @IBOutlet weak var mainTitleLabel : UILabel!
    @IBOutlet weak var subTitleLabel : UILabel!
    @IBOutlet weak var arrowImage : UIImageView!
    @IBOutlet weak var underlineView : UIView!
    
    override func setup(_ indexPath: IndexPath, _ item: (String,String))
    {
        super.setup(indexPath, item)
        
        mainTitleLabel.text = item.0
        subTitleLabel.text = item.1
        arrowImage.isHidden = true
        mainTitleLabel.setupDark(textSize: 17)
        subTitleLabel.setupMainDark(textSize: 18)
    }
    
    func setArrow(hidden: Bool)
    {
        arrowImage.isHidden = hidden
    }
}
