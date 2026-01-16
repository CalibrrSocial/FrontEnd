//
//  ProfileSocialInfoDatasource.swift
//  Calibrr
//
//  Created by Kamil Chmurzynski on 20/06/2019.
//  Copyright © 2019 Calibrr. All rights reserved.
//

import Foundation
import OpenAPIClient

class ProfileSocialInfoDatasource : AStandardItemsCollectionDatasource<ProfileSocialMediaCell, User>
{
    override var noContentMessage: String { get { return "No Social Media" } }
    
    var profile : User? = nil
    
    override func reload()
    {
        super.reload()
        
        if let user = profile {
            items = [user]
        }
    }
}
