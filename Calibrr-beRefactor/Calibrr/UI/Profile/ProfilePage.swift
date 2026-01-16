//
//  ProfilePage.swift
//  Calibrr
//
//  Created by Kamil Chmurzynski on 19/06/2019.
//  Copyright © 2019 Calibrr. All rights reserved.
//

import UIKit
import SDWebImage
import OpenAPIClient

class ProfilePage : APage, UITableViewDelegate, UICollectionViewDelegate
{
    lazy var databaseService = DatabaseService.singleton
    
    @IBOutlet var personalInfoTableView : CBRTableView!
    @IBOutlet var socialInfoCollectionView : CBRCollectionView!
    
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
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "icon_settings").withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(clickEdit(_:)))
        navigationItem.rightBarButtonItem?.tintColor = .white
        
        self.personalInfoTableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateNavidation(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.updateNavidation(false)
    }
    
    override func refreshUI()
    {
        super.refreshUI()
        
        self.profile = databaseService.getProfile().user
        guard let profile = profile else {
            return
        }
        isValidSocialAccount = !(profile.socialInfo?.getAccountValid().isEmpty ?? true)
        personalInfoDatasource.profile = profile.personalInfo
        personalInfoDatasource.myCourses = profile.myCourses
        personalInfoDatasource.bestFriends = profile.myFriends
        personalInfoDatasource.reload()
        self.items = personalInfoDatasource.items
        personalInfoTableView.reloadData()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return isShowBarColor ? .darkContent : .lightContent
    }
    
    @objc func clickEdit(_ sender: UIButton?)
    {
        nav.push(ProfileEditPage())
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
}

extension ProfilePage: UITableViewDataSource {
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
            cell.selectionStyle = .none
            return cell
        } else {
            let cellExtra = isValidSocialAccount ? 2 : 1
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ProfileCell.self), for: indexPath) as! ProfileCell
            cell.setup(indexPath, self.items[indexPath.row - cellExtra])
            return cell
        }
    }
}

extension ProfilePage: UIScrollViewDelegate {

    func updateNavidation(_ isShowBarColor: Bool) {
        let color: UIColor = .clear
        self.nav.updateColor(color: color, isShowShadow: isShowBarColor)
        navigationItem.rightBarButtonItem?.tintColor =  .white
        self.setupMenuButton(0, tintColor: .white)
        self.title = isShowBarColor ? "Profile" : nil
        self.setNeedsStatusBarAppearanceUpdate()
    }
}
