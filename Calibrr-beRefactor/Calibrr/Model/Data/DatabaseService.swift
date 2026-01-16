//
//  DatabaseService.swift
//  Calibrr
//
//  Created by Kamil Chmurzynski on 10/06/2019.
//  Copyright © 2019 Calibrr. All rights reserved.
//

import PromiseKit
import OpenAPIClient

class DatabaseService
{
    static let singleton = DatabaseService()
    
    let imageCache = DataCache<Promise<UIImage>>()
    let documentCache = DataCache<Promise<Data>>()
    
    private var activeProfile : ProfileData? = nil
    
    func setupActiveProfile(_ profile: User, _ token: String, _ tokenReceivedAt: Date)
    {
        activeProfile = ProfileData(user: profile, token: token, tokenReceivedAt: tokenReceivedAt)
    }
    
    func hasProfile() -> Bool
    {
        return activeProfile != nil
    }
    
    func getProfile() -> ProfileData
    {
        return activeProfile!
    }
    
    func clean()
    {
        imageCache.deleteAll()
        documentCache.deleteAll()
    }
    
    func updateAvatar(url: String) {
        self.activeProfile?.user.pictureProfile = url
    }
    
    func updateCover(url: String) {
        self.activeProfile?.user.pictureCover = url
    }
    
    func updateAccount(_ profile: User) {
        print("[DatabaseService] Updating cached profile with classYear: '\(profile.personalInfo?.classYear ?? "nil")'")
        self.activeProfile?.user = profile
        print("[DatabaseService] Cached profile now has classYear: '\(self.activeProfile?.user.personalInfo?.classYear ?? "nil")'")
    }
}
