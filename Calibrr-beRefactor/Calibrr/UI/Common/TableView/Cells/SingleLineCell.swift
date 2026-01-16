//
//  SingleLineCell.swift
//  Calibrr
//
//  Created by Kamil Chmurzynski on 19/06/2019.
//  Copyright © 2019 Calibrr. All rights reserved.
//

import UIKit

class SingleLineCell : ACell<String>
{
    @IBOutlet weak var switchControl: UISwitch!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var underline: UIView!
    
    var switchChanged: ((Bool) -> ())?
    
    override func setup(_ indexPath: IndexPath, _ item: String)
    {
        super.setup(indexPath, item)
        
        titleLabel.text = item
       
    }
    
    var isHiddenSwitchControl: Bool = true {
        didSet {
            switchControl.isHidden = isHiddenSwitchControl
        }
    }
    
    var ghostMode: Bool = false {
        didSet {
            switchControl.isOn = ghostMode
        }
    }
    
    @IBAction private func switchValueChanged(_ sender: Any) {
        switchChanged?(switchControl.isOn)
    }
}
