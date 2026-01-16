//
//  ProfileCell.swift
//  Calibrr
//
//  Created by ZVN20210023 on 02/09/2022.
//  Copyright © 2022 Calibrr. All rights reserved.
//

import UIKit

class ProfileCell: ACell<(String, String, Bool)> {
    @IBOutlet weak var dividerView: UIView!
    @IBOutlet weak var desLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setup(_ indexPath: IndexPath, _ item: (String, String, Bool)) {
        dividerView.isHidden = item.2
        desLabel.text = item.1
        titleLabel.text = item.0
    }
}
