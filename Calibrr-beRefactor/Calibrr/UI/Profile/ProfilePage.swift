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
import PromiseKit

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
        
        // Configure automatic row heights for dynamic content
        personalInfoTableView.rowHeight = UITableView.automaticDimension
        personalInfoTableView.estimatedRowHeight = 60
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "icon_settings").withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(clickEdit(_:)))
        navigationItem.rightBarButtonItem?.tintColor = .white
        
        self.personalInfoTableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateNavidation(true)
        
        // Register for app lifecycle notifications to handle returning from external apps
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAppDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.updateNavidation(false)
        
        // Remove app lifecycle observers to prevent memory leaks
        NotificationCenter.default.removeObserver(
            self,
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }
    
    @objc private func handleAppDidBecomeActive() {
        // Ensure UI is refreshed on the main thread when returning from external apps
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Only refresh if this view controller is visible
            if self.isViewLoaded && self.view.window != nil {
                // Refresh table view to ensure proper state
                self.personalInfoTableView?.reloadData()
                self.socialInfoCollectionView?.reloadData()
            }
        }
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

        // Refresh attribute like states for all visible cells
        refreshAttributeLikeStates()

        // Reconcile like state with server truth so liked/likeCount persist across app restarts
        let myId = profile.id
        ProfileAPI.getUser(id: myId).done { updated in
            guard var current = self.profile else { return }
            // Merge only fields relevant to likes to avoid overwriting locally persisted profile details
            current.liked = updated.liked
            current.likeCount = updated.likeCount
            DatabaseService.singleton.updateAccount(current)
            self.profile = current
            // Reload just the header row to reflect heart/count
            let headerIndex = IndexPath(row: 0, section: 0)
            if self.personalInfoTableView.indexPathsForVisibleRows?.contains(headerIndex) == true,
               let cell = self.personalInfoTableView.cellForRow(at: headerIndex) as? HeaderProfileCell {
                cell.setLikeUI(liked: current.liked ?? false, count: current.likeCount ?? 0, isEnabled: true)
            } else {
                self.personalInfoTableView.reloadData()
            }
        }.catch { _ in }
    }
    
    private func refreshAttributeLikeStates() {
        // Refresh attribute like states for all visible ProfileCell instances
        guard let visibleIndexPaths = personalInfoTableView.indexPathsForVisibleRows else { return }
        
        // Add small delays between API calls to prevent rate limiting
        var delay: TimeInterval = 0.0
        
        for indexPath in visibleIndexPaths {
            if let cell = personalInfoTableView.cellForRow(at: indexPath) as? ProfileCell {
                // Trigger a reload of the like state for this cell with a small delay
                if let profileId = self.profile?.id {
                    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                        cell.configureForProfile(profileId)
                    }
                    delay += 0.1 // 100ms delay between each API call
                }
            }
        }
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
        // Ensure we're on the main thread for UI operations
        DispatchQueue.main.async { [weak self] in
            guard self != nil else { return }
            
            let app = UIApplication.shared
            var cleanUsername = username
            
            // Clean up username
            if let url = URL(string: username),
               let name = url.pathComponents.last {
                cleanUsername = name
            }
            cleanUsername = cleanUsername.replacingOccurrences(of: "@", with: "")
            
            // Add a small delay to ensure UI has fully processed the tap before opening external app
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                var success = false
                
                switch platform {
                case "Instagram":
                    success = app.open(Applications.Instagram(), action: .username(cleanUsername))
                case "Facebook":
                    success = app.open(Applications.FacebookCustom(), action: .userName(cleanUsername))
                case "VSCO":
                    success = app.open(Applications.VSCOCustom(), action: .userName(cleanUsername))
                case "X (Twitter)":
                    success = app.open(Applications.TwitterCustom(), action: .userName(cleanUsername))
                case "LinkedIn":
                    success = app.open(Applications.LinkedinCustom(), action: .userName(cleanUsername))
                case "Snapchat":
                    success = app.open(Applications.SnapChatCustom(), action: .userName(cleanUsername))
                case "TikTok":
                    success = app.open(Applications.TikTok(), action: .userName(cleanUsername))
                default:
                    Alert.Basic(message: "Unable to open \(platform)")
                    return
                }
                
                // Log if opening failed
                if !success {
                    print("Failed to open \(platform) for username: \(cleanUsername)")
                }
            }
        }
    }
    
    private func handleAttributeLikeToggle(for cell: ProfileCell?) {
        print("🔥 handleAttributeLikeToggle called!")
        guard let cell = cell,
              let profile = self.profile else { 
            print("🔥 handleAttributeLikeToggle: Missing cell or profile")
            return 
        }
        
        let myId = DatabaseService.singleton.getProfile().user.id
        let targetId = profile.id
        
        // Get current state
        var currentLiked = cell.currentAttributeLikeState()
        var currentCount = cell.currentAttributeLikesCount()
        print("🔥 ProfilePage currentLiked: \(currentLiked), currentCount: \(currentCount)")
        
        // Optimistic toggle
        let newLikedState = !currentLiked
        let newCount = max(0, newLikedState ? currentCount + 1 : currentCount - 1)
        cell.setAttributeLikeUI(liked: newLikedState, count: newCount, isEnabled: false)
        
        // Get attribute info from cell
        print("🔥 Getting attribute info - category: \(cell.attributeCategory ?? "nil"), name: \(cell.attributeName ?? "nil")")
        guard let attributeCategory = cell.attributeCategory,
              let attributeName = cell.attributeName else {
            print("🔥 Missing attribute info, falling back to profile like system")
            cell.setAttributeLikeUI(liked: !currentLiked, count: currentLiked ? currentCount - 1 : currentCount + 1, isEnabled: true)
            return
        }
        print("🔥 Using attribute like system - category: \(attributeCategory), name: \(attributeName)")
        
        // Make API call using dedicated attribute like endpoints
        let endpoint = "https://api.calibrr.com/api/profile/\(myId)/attributes/like"
        print("🔥 ProfilePage Making API call to: \(endpoint)")
        
        guard let url = URL(string: endpoint) else {
            print("🔥 ProfilePage Failed to create URL from: \(endpoint)")
            cell.setAttributeLikeUI(liked: !currentLiked, count: currentLiked ? currentCount - 1 : currentCount + 1, isEnabled: true)
            return
        }
        print("🔥 ProfilePage URL created successfully")
        
        var request = URLRequest(url: url)
        request.httpMethod = currentLiked ? "DELETE" : "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add authorization header
        let token = DatabaseService.singleton.getProfile().token
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        // Add attribute parameters in request body
        let body: [String: Any] = [
            "profileId": targetId,
            "category": attributeCategory,
            "attribute": attributeName
        ]
        print("🔥 ProfilePage Request body: \(body)")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            print("🔥 ProfilePage JSON serialization successful")
        } catch {
            print("🔥 ProfilePage JSON serialization failed: \(error)")
            cell.setAttributeLikeUI(liked: !currentLiked, count: currentLiked ? currentCount - 1 : currentCount + 1, isEnabled: true)
            return
        }

        // Make the API call
        print("🔥 ProfilePage About to make API call with method: \(request.httpMethod ?? "nil")")
        URLSession.shared.dataTask(with: request) { data, response, error in
            print("🔥 ProfilePage API call completed")
            DispatchQueue.main.async {
                if let error = error {
                    // Revert optimistic update
                    cell.setAttributeLikeUI(liked: currentLiked, count: currentCount, isEnabled: true)
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 {
                        // Success - keep optimistic update and force refresh for accurate count
                        cell.setAttributeLikeUI(liked: newLikedState, count: newCount, isEnabled: true)
                        
                        // Force refresh after short delay to get accurate server data
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            cell.forceRefreshLikeState()
                        }
                    } else {
                        // Error - revert optimistic update
                        cell.setAttributeLikeUI(liked: currentLiked, count: currentCount, isEnabled: true)
                    }
                }
            }
        }.resume()
        print("🔥 ProfilePage API call started (resume called)")
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
                let initialLiked = profile.liked ?? false
                let initialCount = profile.likeCount ?? 0
                cell.setLikeUI(liked: initialLiked, count: initialCount, isEnabled: true)
                // TEMPORARILY DISABLED OLD PROFILE LIKE SYSTEM TO TEST ATTRIBUTE LIKES
                /*
                cell.onToggleLike = { [weak self, weak cell] () -> Void in
                    guard let self = self else { return }
                    let myId = DatabaseService.singleton.getProfile().user.id
                    let targetId = myId // self-like
                    var currentLiked = cell?.currentLikeState() ?? initialLiked
                    var currentCount = cell?.currentLikesCount() ?? initialCount
                    // Optimistic toggle
                    currentLiked.toggle()
                    currentCount = max(0, currentLiked ? currentCount + 1 : currentCount - 1)
                    cell?.setLikeUI(liked: currentLiked, count: currentCount, isEnabled: false)
                    let request: PromiseKit.Promise<Void> = currentLiked ? ProfileAPI.likeProfile(id: myId, profileLikedId: targetId) : ProfileAPI.unlikeProfile(id: myId, profileLikedId: targetId)
                    request.done {
                        // Refresh truth from server and persist
                        ProfileAPI.getUser(id: myId).done { updated in
                            // Persist to active profile so it survives refresh/relaunch until next sync
                            DatabaseService.singleton.updateAccount(updated)
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
                */
                cell.onOpenLikes = { [weak self] in
                    guard let self = self, let userId = self.profile?.id else { return }
                    let vc = ProfileLikesPanelPage()
                    vc.configure(for: userId, viewingOwnProfile: true)
                    self.nav.push(vc)
                }
                
                // Hide Block and Report buttons on own profile
                cell.hideBlockReportButtons()
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
            
            // Configure attribute likes for this cell
            if let profileId = self.profile?.id {
                print("ProfilePage: Configuring cell with profileId: \(profileId)")
                cell.configureForProfile(profileId)
                cell.onToggleAttributeLike = { [weak self, weak cell] in
                    print("ProfilePage: onToggleAttributeLike callback triggered")
                    self?.handleAttributeLikeToggle(for: cell)
                }
            } else {
                print("ProfilePage: WARNING - profile?.id is nil, cannot configure cell")
            }
            
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
