//
//  ProfileData.swift
//  Calibrr
//
//
//  Copyright © Calibrr. All rights reserved.
//

import Foundation
import OpenAPIClient

class ProfileData
{
    var user: User
    let token: String
    let tokenReceivedAt: Date
    
//    let creditCards = DataStore<CreditCard>({c in return c._id!})
    
    init(user: User, token: String, tokenReceivedAt: Date)
    {
        self.user = user
        self.token = token
        self.tokenReceivedAt = tokenReceivedAt
    }
}
