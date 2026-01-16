//
//  ProfileSocialInfoDatasource.swift
//  Calibrr
//
//
//  Copyright © Calibrr. All rights reserved.
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
