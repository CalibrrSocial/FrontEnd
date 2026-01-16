//
//  CommentCell.swift
//  Calibrr
//
//
//  Copyright © Calibrr. All rights reserved.
//

import UIKit

class CommentCell : ACell<(String, String)>
{
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    
    override func setup(_ indexPath: IndexPath, _ item: (String,String))
    {
        super.setup(indexPath, item)
        
        titleLabel.text = item.0
        commentLabel.text = item.1
    }
}
