//
//  ProfileFriendPage.swift
//  Calibrr
//
//  Created by Kamil Chmurzynski on 20/06/2019.
//  Copyright © 2019 Calibrr. All rights reserved.
//

import UIKit
import OpenAPIClient

class ProfileFriendPage: APage, UITableViewDelegate, UICollectionViewDelegate
{
    
    @IBOutlet var personalInfoTableView : CBRTableView!
    @IBOutlet var socialInfoCollectionView : CBRCollectionView!
    
    var friendId : String? = nil
    var firstName: String?
    
    private let personalInfoDatasource = ProfilePersonalInfoDatasource()
    private let socialInfoDatasource = ProfileSocialInfoDatasource()
    
    var profile: User?
    var items: [(String, String, Bool)] = []
    var isShowBarColor: Bool = false
    var isValidSocialAccount: Bool = false
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        personalInfoTableView.dataSource = self
        socialInfoCollectionView.dataSource = socialInfoDatasource
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateNavidation(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.updateNavidation(false)
    }
    
    override func reloadData()
    {
        super.reloadData()
        
        nav.showTransparentLoading()
        
        if let id = friendId {
            ProfileAPI.getUser(id: id).done{ result in
                self.processFriendProfile(result)
            }.ensure{
                self.nav.hideTransparentLoading()
                self.refreshUI()
            }.catchCBRError(show: true, from: self)
        }
    }
    
    override func refreshUI()
    {
        super.refreshUI()
        
        personalInfoDatasource.reload()
        personalInfoTableView.reloadData()
        
        socialInfoDatasource.reload()
        socialInfoCollectionView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        //TODO: show social network
        Alert.Basic(message: "TODO show Social Network")
    }
    
    private func processFriendProfile(_ profile: User)
    {
        self.profile = profile
        isValidSocialAccount = !(profile.socialInfo?.getAccountValid().isEmpty ?? true)
        personalInfoDatasource.profile = profile.personalInfo
        personalInfoDatasource.myCourses = profile.myCourses
        personalInfoDatasource.bestFriends = profile.myFriends
        personalInfoDatasource.reload()
        self.items = personalInfoDatasource.items
        socialInfoDatasource.profile = profile
        self.refreshUI()
    }
}

extension ProfileFriendPage: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let cellExtra = isValidSocialAccount ? 2 : 1
        return self.items.count + cellExtra
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HeaderProfileCell.self), for: indexPath) as! HeaderProfileCell
            if let profile = self.profile {
                cell.configureCell(profile)
            }
            return cell
        } else if indexPath.row == 1, isValidSocialAccount {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SocialLinkTableViewCell.self), for: indexPath) as! SocialLinkTableViewCell
            cell.setupData(account: profile?.socialInfo)
            return cell
        } else {
            let cellExtra = isValidSocialAccount ? 2 : 1
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ProfileCell.self), for: indexPath) as! ProfileCell
            cell.setup(indexPath, self.items[indexPath.row - cellExtra])
            return cell
        }
    }
}

extension ProfileFriendPage: UIScrollViewDelegate {
    
    func updateNavidation(_ isShowBarColor: Bool) {
        let color: UIColor = .clear
        self.nav.updateColor(color: color, isShowShadow: isShowBarColor)
        navigationItem.rightBarButtonItem?.tintColor = .white
        self.setupBackButton(tintColor: .white)
        if let firstName = self.firstName,
            !firstName.isEmpty {
            self.title = isShowBarColor ? "\(firstName)'s Profile" : nil
        } else {
            self.title = nil
        }
        
        self.setNeedsStatusBarAppearanceUpdate()
    }
}
