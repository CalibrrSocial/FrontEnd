//
//  ProfileFriendPage.swift
//  Calibrr
//
//  Created by Kamil Chmurzynski on 20/06/2019.
//  Copyright © 2019 Calibrr. All rights reserved.
//

import UIKit
import OpenAPIClient
import PromiseKit

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
    var preferDarkBackButton: Bool = false
    
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
        
        // Hide the collection view since we're using SocialLinkTableViewCell in the table view
        socialInfoCollectionView.isHidden = true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        // Handle social media icon taps by opening the respective social media app/website
        guard let profile = self.profile,
              let socialInfo = profile.socialInfo else {
            Alert.Basic(message: "No social media information available")
            return
        }
        
        // Get all social media accounts
        var socialAccounts: [(String, String)] = []
        
        if let instagram = socialInfo.instagram, !instagram.isEmpty {
            socialAccounts.append(("Instagram", instagram))
        }
        if let facebook = socialInfo.facebook, !facebook.isEmpty {
            socialAccounts.append(("Facebook", facebook))
        }
        if let snapchat = socialInfo.snapchat, !snapchat.isEmpty {
            socialAccounts.append(("Snapchat", snapchat))
        }
        if let linkedin = socialInfo.linkedIn, !linkedin.isEmpty {
            socialAccounts.append(("LinkedIn", linkedin))
        }
        if let twitter = socialInfo.twitter, !twitter.isEmpty {
            socialAccounts.append(("X (Twitter)", twitter))
        }
        if let vsco = socialInfo.vsco, !vsco.isEmpty {
            socialAccounts.append(("VSCO", vsco))
        }
        if let tiktok = socialInfo.tiktok, !tiktok.isEmpty {
            socialAccounts.append(("TikTok", tiktok))
        }
        
        // Open the selected social media account
        if indexPath.row < socialAccounts.count {
            let (platform, username) = socialAccounts[indexPath.row]
            openSocialMedia(platform: platform, username: username)
        }
    }
    
    private func openSocialMedia(platform: String, username: String) {
        let app = UIApplication.shared
        var cleanUsername = username
        
        // Clean up username
        if let url = URL(string: username),
           let name = url.pathComponents.last {
            cleanUsername = name
        }
        cleanUsername = cleanUsername.replacingOccurrences(of: "@", with: "")
        
        switch platform {
        case "Instagram":
            app.open(Applications.Instagram(), action: .username(cleanUsername))
        case "Facebook":
            app.open(Applications.FacebookCustom(), action: .userName(cleanUsername))
        case "VSCO":
            app.open(Applications.VSCOCustom(), action: .userName(cleanUsername))
        case "X (Twitter)":
            app.open(Applications.TwitterCustom(), action: .userName(cleanUsername))
        case "LinkedIn":
            app.open(Applications.LinkedinCustom(), action: .userName(cleanUsername))
        case "Snapchat":
            app.open(Applications.SnapChatCustom(), action: .userName(cleanUsername))
        case "TikTok":
            app.open(Applications.TikTok(), action: .userName(cleanUsername))
        default:
            Alert.Basic(message: "Unable to open \(platform)")
        }
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
                let initialLiked = profile.liked ?? false
                let initialCount = profile.likeCount ?? 0
                cell.setLikeUI(liked: initialLiked, count: initialCount, isEnabled: true)
                cell.onToggleLike = { [weak self, weak cell] () -> Void in
                    guard let self = self, let targetId = self.friendId else { return }
                    let myId = DatabaseService.singleton.getProfile().user.id
                    var currentLiked = cell?.currentLikeState() ?? initialLiked
                    var currentCount = cell?.currentLikesCount() ?? initialCount
                    // Optimistic toggle
                    currentLiked.toggle()
                    currentCount = max(0, currentLiked ? currentCount + 1 : currentCount - 1)
                    cell?.setLikeUI(liked: currentLiked, count: currentCount, isEnabled: false)
                    let request: Promise<Void> = currentLiked ? ProfileAPI.likeProfile(id: myId, profileLikedId: targetId) : ProfileAPI.unlikeProfile(id: myId, profileLikedId: targetId)
                    request.done {
                        // Refresh truth from server
                        ProfileAPI.getUser(id: targetId).done { updated in
                            self.profile = updated
                            let sLiked = updated.liked ?? currentLiked
                            let sCount = updated.likeCount ?? currentCount
                            cell?.setLikeUI(liked: sLiked, count: sCount, isEnabled: true)
                        }.catch { _ in
                            cell?.setLikeUI(liked: currentLiked, count: currentCount, isEnabled: true)
                        }
                    }.catch { _ in
                        // Rollback on failure
                        let rollbackLiked = !currentLiked
                        let rollbackCount = max(0, rollbackLiked ? currentCount + 1 : currentCount - 1)
                        cell?.setLikeUI(liked: rollbackLiked, count: rollbackCount, isEnabled: true)
                    }
                }
                cell.onOpenLikes = { [weak self] in
                    guard let self = self, let userId = self.friendId else { return }
                    let vc = ProfileLikesPanelPage()
                    vc.configure(for: userId, viewingOwnProfile: false)
                    self.nav.push(vc)
                }
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
        self.setupBackButton(tintColor: preferDarkBackButton ? .label : .white)
        if let firstName = self.firstName,
            !firstName.isEmpty {
            self.title = isShowBarColor ? "\(firstName)'s Profile" : nil
        } else {
            self.title = nil
        }
        
        self.setNeedsStatusBarAppearanceUpdate()
    }
}
