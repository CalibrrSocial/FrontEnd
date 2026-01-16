//
//  MenuPage.swift
//  Calibrr
//
//
//  Copyright © Calibrr. All rights reserved.
//

import UIKit
import SDWebImage
import OpenAPIClient

class MenuPage : AMenuPage
{
    static let singleton = MenuPage()
    
    lazy var databaseService = DatabaseService.singleton
    
    @IBOutlet var titleLabel : UILabel!
    @IBOutlet var coverPic : UIImageView!
    @IBOutlet var nameLabel : UILabel!
    @IBOutlet var profilePic : UIImageView!
    @IBOutlet var viewProfileButton : CBRButton!
    @IBOutlet var searchByNameButton : UIButton!
    @IBOutlet var searchByDistanceButton : UIButton!
    @IBOutlet var analyticsButton : UIButton!
    @IBOutlet var settingsButton : UIButton!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        profilePic.roundFull()
        viewProfileButton.shadow(6, offset: 2)
    }
    
    @IBAction func clickProfile(_ sender: UIButton)
    {
        transitionTo(ProfilePage())
    }
    
    @IBAction func clickSearchByName(_ sender: UIButton)
    {
        transitionTo(SearchUsersByNamePage())
    }
    
    @IBAction func clickSearchByDistance(_ sender: UIButton)
    {
        transitionTo(SearchUsersByDistancePage())
    }
    
    @IBAction func clickAnalytics(_ sender: UIButton)
    {
        transitionTo(AnalyticsPage())
    }
    
    @IBAction func clickSettings(_ sender: UIButton)
    {
        transitionTo(SettingsPage())
    }
    
    override func refreshUI()
    {
        super.refreshUI()
        
        let profile = databaseService.getProfile().user
        
        nameLabel.text = "\(profile.firstName ?? "") \(profile.lastName ?? "")"
        
        if let image = profile.pictureCover, let url = URL(string: image), url.lastPathComponent != "cover" {
            coverPic.sd_setImage(with: url)
        } else {
            coverPic.image = UIImage(named: "background")
        }
        if let image = profile.pictureProfile, let url = URL(string: image) {
            profilePic.sd_setImage(with: url)
        } else {
            profilePic.image = UIImage(named: "icon_avatar_placeholder")
        }
    }
}
