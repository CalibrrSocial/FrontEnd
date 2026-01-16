//
//  ProfileSocialMediaCell.swift
//  Calibrr
//
//  Created by Kamil Chmurzynski on 20/06/2019.
//  Copyright © 2019 Calibrr. All rights reserved.
//

import UIKit
import SDWebImage
import OpenAPIClient

class ProfileSocialMediaCell : ACollectionCell<User>
{
    @IBOutlet var icon : UIImageView!
    @IBOutlet var nameLabel : UILabel!
    
    override func setup(_ indexPath: IndexPath, _ item: User)
    {
        super.setup(indexPath, item)
        
//        icon.sd_setImage(with: URL(string: item.socialSiteLogo)!)
//        nameLabel.text = item.socialSiteName
    }
}
