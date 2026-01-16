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
                
                // Block and Report functionality
                cell.onBlockUser = { [weak self] in
                    self?.showBlockConfirmation()
                }
                
                cell.onReportUser = { [weak self] in
                    self?.showReportDialog()
                }
                
                // Report Broken Link functionality
                cell.onReportBrokenLink = { [weak self] in
                    self?.showReportBrokenLinkDialog()
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
            
            // Configure attribute likes for this cell
            if let profileId = self.profile?.id {
                cell.configureForProfile(profileId)
                cell.onToggleAttributeLike = { [weak self, weak cell] in
                    self?.handleAttributeLikeToggle(for: cell)
                }
            }
            
            return cell
        }
    }
    
    private func handleAttributeLikeToggle(for cell: ProfileCell?) {
        guard let cell = cell,
              let profile = self.profile else { return }
        
        let myId = DatabaseService.singleton.getProfile().user.id
        let targetId = profile.id
        
        // Get current state
        var currentLiked = cell.currentAttributeLikeState()
        var currentCount = cell.currentAttributeLikesCount()
        
        // Optimistic toggle
        currentLiked.toggle()
        currentCount = max(0, currentLiked ? currentCount + 1 : currentCount - 1)
        cell.setAttributeLikeUI(liked: currentLiked, count: currentCount, isEnabled: false)
        
        // Get attribute info from cell
        guard let attributeCategory = cell.attributeCategory,
              let attributeName = cell.attributeName else {
            print("Missing attribute information for like")
            cell.setAttributeLikeUI(liked: !currentLiked, count: currentLiked ? currentCount - 1 : currentCount + 1, isEnabled: true)
            return
        }
        
        // Make API call using existing profile like endpoint with attribute parameters
        let endpoint = "https://api.calibrr.com/api/profile/\(targetId)/likes?profileLikedId=\(targetId)"
        
        print("Attribute like endpoint: \(endpoint)")
        print("Current liked state: \(currentLiked), will use method: \(currentLiked ? "DELETE" : "POST")")
        print("Target ID: \(targetId), My ID: \(myId)")
        
        guard let url = URL(string: endpoint) else {
            print("Invalid URL for attribute like")
            cell.setAttributeLikeUI(liked: !currentLiked, count: currentLiked ? currentCount - 1 : currentCount + 1, isEnabled: true)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = currentLiked ? "DELETE" : "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add authorization header
        let token = DatabaseService.singleton.getProfile().token
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        print("Using auth token: \(token.prefix(20))...") // Log first 20 chars for security
        
        // Add attribute parameters in request body
        let body: [String: Any] = [
            "attributeCategory": attributeCategory,
            "attributeName": attributeName,
            "profileLikeId": targetId,
            "profileLikedId": targetId
        ]
        
        print("Request body: \(body)")
        print("Request headers: \(request.allHTTPHeaderFields ?? [:])")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            print("Failed to serialize attribute like request body: \(error)")
            cell.setAttributeLikeUI(liked: !currentLiked, count: currentLiked ? currentCount - 1 : currentCount + 1, isEnabled: true)
            return
        }
        
        // Make the API call
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Attribute like API error: \(error)")
                    // Revert optimistic update
                    cell.setAttributeLikeUI(liked: !currentLiked, count: currentLiked ? currentCount - 1 : currentCount + 1, isEnabled: true)
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    print("Attribute like API response: \(httpResponse.statusCode)")
                    
                    // Log response body for debugging
                    if let data = data {
                        if let responseString = String(data: data, encoding: .utf8) {
                            print("Response body: \(responseString)")
                        }
                    }
                    
                    if httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 {
                        // Success - keep the optimistic update
                        cell.setAttributeLikeUI(liked: currentLiked, count: currentCount, isEnabled: true)
                        print("Attribute like \(currentLiked ? "added" : "removed") successfully")
                    } else {
                        // Error - revert optimistic update
                        cell.setAttributeLikeUI(liked: !currentLiked, count: currentLiked ? currentCount - 1 : currentCount + 1, isEnabled: true)
                        print("Attribute like API failed with status: \(httpResponse.statusCode)")
                        print("Headers: \(httpResponse.allHeaderFields)")
                    }
                }
            }
        }.resume()
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
    
    // MARK: - Block and Report functionality
    
    private func showBlockConfirmation() {
        guard let friendId = self.friendId,
              let friendName = self.profile?.firstName else { return }
        
        let alert = UIAlertController(
            title: "Block \(friendName)?",
            message: "You and \(friendName) will no longer be able to see each other on the app. You can unblock them later in Settings.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Block", style: .destructive) { [weak self] _ in
            self?.blockUser()
        })
        
        present(alert, animated: true)
    }
    
    private func showReportDialog() {
        guard let friendId = self.friendId,
              let friendName = self.profile?.firstName else { return }
        
        let alert = UIAlertController(
            title: "Report \(friendName)",
            message: "Please describe why you're reporting this user. They will also be blocked automatically.",
            preferredStyle: .alert
        )
        
        alert.addTextField { textField in
            textField.placeholder = "Reason for reporting..."
            textField.autocapitalizationType = .sentences
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Report & Block", style: .destructive) { [weak self] _ in
            let reason = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            if reason.isEmpty {
                self?.showErrorAlert(message: "Please provide a reason for reporting.")
                return
            }
            self?.reportUser(reason: reason)
        })
        
        present(alert, animated: true)
    }
    
    private func showReportBrokenLinkDialog() {
        guard let profile = self.profile,
              let socialInfo = profile.socialInfo else {
            showErrorAlert(message: "No social media links to report.")
            return
        }
        
        let friendName = profile.firstName ?? "this user"
        
        // Get all available social platforms
        var availablePlatforms: [(platform: String, hasLink: Bool)] = []
        
        if let instagram = socialInfo.instagram, !instagram.isEmpty {
            availablePlatforms.append(("Instagram", true))
        }
        if let facebook = socialInfo.facebook, !facebook.isEmpty {
            availablePlatforms.append(("Facebook", true))
        }
        if let snapchat = socialInfo.snapchat, !snapchat.isEmpty {
            availablePlatforms.append(("Snapchat", true))
        }
        if let linkedin = socialInfo.linkedIn, !linkedin.isEmpty {
            availablePlatforms.append(("LinkedIn", true))
        }
        if let twitter = socialInfo.twitter, !twitter.isEmpty {
            availablePlatforms.append(("X (Twitter)", true))
        }
        if let vsco = socialInfo.vsco, !vsco.isEmpty {
            availablePlatforms.append(("VSCO", true))
        }
        if let tiktok = socialInfo.tiktok, !tiktok.isEmpty {
            availablePlatforms.append(("TikTok", true))
        }
        
        if availablePlatforms.isEmpty {
            showErrorAlert(message: "This user has no social media links to report.")
            return
        }
        
        // Create action sheet for platform selection
        let actionSheet = UIAlertController(
            title: "Report Broken Link",
            message: "Which social media link for \(friendName) is broken?",
            preferredStyle: .actionSheet
        )
        
        // Add option for each platform
        for platform in availablePlatforms {
            actionSheet.addAction(UIAlertAction(title: platform.platform, style: .default) { [weak self] _ in
                self?.confirmReportBrokenLink(platform: platform.platform)
            })
        }
        
        // Add "Multiple Links" option if there are multiple platforms
        if availablePlatforms.count > 1 {
            actionSheet.addAction(UIAlertAction(title: "Multiple Links Are Broken", style: .default) { [weak self] _ in
                self?.showMultipleBrokenLinksDialog(availablePlatforms: availablePlatforms.map { $0.platform })
            })
        }
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        // For iPad
        if let popover = actionSheet.popoverPresentationController {
            popover.sourceView = self.view
            popover.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        present(actionSheet, animated: true)
    }
    
    private func showMultipleBrokenLinksDialog(availablePlatforms: [String]) {
        let alert = UIAlertController(
            title: "Select Broken Links",
            message: "Select all platforms with broken links:",
            preferredStyle: .alert
        )
        
        // Create a simplified version with text input
        let message = availablePlatforms.joined(separator: ", ")
        alert.message = "Enter the platforms with broken links separated by commas:\n(Available: \(message))"
        
        alert.addTextField { textField in
            textField.placeholder = "e.g., Instagram, Facebook, TikTok"
            textField.autocapitalizationType = .words
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Report", style: .destructive) { [weak self] _ in
            guard let input = alert.textFields?.first?.text,
                  !input.isEmpty else {
                self?.showErrorAlert(message: "Please enter at least one platform.")
                return
            }
            
            let platforms = input.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            if platforms.isEmpty {
                self?.showErrorAlert(message: "Please enter at least one platform.")
                return
            }
            
            self?.reportBrokenLinks(platforms: platforms)
        })
        
        present(alert, animated: true)
    }
    
    private func confirmReportBrokenLink(platform: String) {
        guard let friendName = self.profile?.firstName else { return }
        
        let alert = UIAlertController(
            title: "Report Broken \(platform) Link?",
            message: "\(friendName) will receive an email notification asking them to fix their \(platform) link.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Report", style: .destructive) { [weak self] _ in
            self?.reportBrokenLinks(platforms: [platform])
        })
        
        present(alert, animated: true)
    }
    
    private func reportBrokenLinks(platforms: [String]) {
        guard let friendId = self.friendId,
              let profile = self.profile else { return }
        
        let myId = DatabaseService.singleton.getProfile().user.id
        let myProfile = DatabaseService.singleton.getProfile().user
        let reporterName = [myProfile.firstName, myProfile.lastName].compactMap { $0 }.joined(separator: " ")
        
        // Show loading
        let loadingAlert = UIAlertController(title: "Reporting broken links...", message: nil, preferredStyle: .alert)
        present(loadingAlert, animated: true)
        
        // Call API to report broken links
        self.reportBrokenLinksAPI(
            reporterId: myId,
            reportedUserId: friendId,
            platforms: platforms,
            reporterName: reporterName.isEmpty ? "Someone" : reporterName
        ).done { [weak self] in
            loadingAlert.dismiss(animated: true) {
                let message = platforms.count == 1 
                    ? "The broken \(platforms[0]) link has been reported. \(profile.firstName ?? "The user") will be notified via email."
                    : "The broken links have been reported. \(profile.firstName ?? "The user") will be notified via email."
                self?.showSuccessAlert(message: message) {
                    // Don't pop the view, just dismiss the alert
                }
            }
        }.catch { [weak self] (error: Error) in
            loadingAlert.dismiss(animated: true) {
                self?.showErrorAlert(message: "Failed to report broken links. Please try again.")
            }
        }
    }
    
    private func blockUser() {
        guard let friendId = self.friendId else { 
            print("❌ [BLOCK USER] No friendId available")
            return 
        }
        let myId = DatabaseService.singleton.getProfile().user.id
        
        print("🚫 [BLOCK USER] Starting block process")
        print("🚫 [BLOCK USER] My ID: \(myId)")
        print("🚫 [BLOCK USER] Blocking user ID: \(friendId)")
        
        // Show loading
        let loadingAlert = UIAlertController(title: "Blocking user...", message: nil, preferredStyle: .alert)
        present(loadingAlert, animated: true)
        
        self.blockUserAPI(myId: myId, userToBlockId: friendId).done { [weak self] in
            print("✅ [BLOCK USER] Block API call successful")
            loadingAlert.dismiss(animated: true) {
                self?.showSuccessAlert(message: "User has been blocked successfully.") {
                    self?.navigationController?.popViewController(animated: true)
                }
            }
        }.catch { [weak self] (error: Error) in
            print("❌ [BLOCK USER] Block API call failed: \(error)")
            loadingAlert.dismiss(animated: true) {
                self?.showErrorAlert(message: "Failed to block user. Please try again.")
            }
        }
    }
    
    private func reportUser(reason: String) {
        guard let friendId = self.friendId else { return }
        let myId = DatabaseService.singleton.getProfile().user.id
        
        // Show loading
        let loadingAlert = UIAlertController(title: "Reporting user...", message: nil, preferredStyle: .alert)
        present(loadingAlert, animated: true)
        
        self.reportUserAPI(myId: myId, reportedUserId: friendId, reason: reason).done { [weak self] in
            loadingAlert.dismiss(animated: true) {
                self?.showSuccessAlert(message: "User has been reported and blocked successfully.") {
                    self?.navigationController?.popViewController(animated: true)
                }
            }
        }.catch { [weak self] (error: Error) in
            loadingAlert.dismiss(animated: true) {
                self?.showErrorAlert(message: "Failed to report user. Please try again.")
            }
        }
    }
    
    private func showSuccessAlert(message: String, completion: @escaping () -> Void) {
        let alert = UIAlertController(title: "Success", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion()
        })
        present(alert, animated: true)
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - API Methods
    
    private func reportBrokenLinksAPI(reporterId: String, reportedUserId: String, platforms: [String], reporterName: String) -> Promise<Void> {
        let deferred = Promise<Void>.pending()
        
        print("🔗 [BROKEN LINKS] Starting API call for user: \(reportedUserId)")
        print("🔗 [BROKEN LINKS] Platforms: \(platforms)")
        print("🔗 [BROKEN LINKS] Reporter: \(reporterName)")
        
        // First, get the reported user's email address
        ProfileAPI.getUser(id: reportedUserId).done { [weak self] reportedUser in
            print("🔗 [BROKEN LINKS] Got user data: \(reportedUser.email ?? "NO EMAIL")")
            
            guard let recipientEmail = reportedUser.email else {
                print("❌ [BROKEN LINKS] User has no email address")
                let error = NSError(domain: "MissingEmail", code: -1, userInfo: [NSLocalizedDescriptionKey: "Reported user has no email address"])
                deferred.resolver.reject(error)
                return
            }
            
            print("🔗 [BROKEN LINKS] Calling email notification API...")
            
            // Call the email notification endpoint with dead_link_reported type
            self?.sendEmailNotification(
                notificationType: "dead_link_reported",
                additionalData: [
                    "recipientEmail": recipientEmail,
                    "platforms": platforms,
                    "reporterName": reporterName
                ]
            ).done {
                print("✅ [BROKEN LINKS] Email notification sent successfully")
                deferred.resolver.fulfill(())
            }.catch { error in
                print("❌ [BROKEN LINKS] Email notification failed: \(error)")
                deferred.resolver.reject(error)
            }
        }.catch { error in
            print("❌ [BROKEN LINKS] Failed to get user data: \(error)")
            deferred.resolver.reject(error)
        }
        
        return deferred.promise
    }
    
    private func sendEmailNotification(notificationType: String, additionalData: [String: Any]) -> Promise<Void> {
        let deferred = Promise<Void>.pending()
        
        // Use the Calibrr API endpoint for broken link reporting
        // This will be handled by the backend which can then invoke the emailNotificationFinal Lambda
        let urlString = "\(APIKeys.BASE_API_URL)/broken-links/report"
        print("📧 [BROKEN LINKS API] URL: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            print("❌ [BROKEN LINKS API] Invalid URL: \(urlString)")
            deferred.resolver.reject(NSError(domain: "InvalidURL", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
            return deferred.promise
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add authorization header using the same pattern as other API calls
        if let token = OpenAPIClientAPI.customHeaders[APIKeys.HTTP_AUTHORIZATION_HEADER] {
            let tokenPrefix = String(token.prefix(20))
            print("🔑 [BROKEN LINKS API] Using token: \(tokenPrefix)...")
            request.setValue(token, forHTTPHeaderField: APIKeys.HTTP_AUTHORIZATION_HEADER)
        } else {
            print("❌ [BROKEN LINKS API] No authorization token found")
        }
        
        // Extract the specific data we need for the broken links API
        let platforms = additionalData["platforms"] as? [String] ?? []
        let recipientEmail = additionalData["recipientEmail"] as? String ?? ""
        let reporterName = additionalData["reporterName"] as? String ?? ""
        
        let parameters: [String: Any] = [
            "platforms": platforms,
            "recipientEmail": recipientEmail,
            "reporterName": reporterName
        ]
        
        print("📧 [BROKEN LINKS API] Parameters: \(parameters)")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        } catch {
            print("❌ [BROKEN LINKS API] JSON serialization failed: \(error)")
            deferred.resolver.reject(error)
            return deferred.promise
        }
        
        print("📧 [BROKEN LINKS API] Making request...")
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ [BROKEN LINKS API] Network error: \(error)")
                deferred.resolver.reject(error)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📧 [BROKEN LINKS API] Response status: \(httpResponse.statusCode)")
                if let data = data, let responseString = String(data: data, encoding: .utf8) {
                    print("📧 [BROKEN LINKS API] Response body: \(responseString)")
                }
                
                if httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 {
                    print("✅ [BROKEN LINKS API] Broken link report sent successfully")
                    deferred.resolver.fulfill(())
                } else {
                    print("❌ [BROKEN LINKS API] HTTP Error \(httpResponse.statusCode)")
                    let error = NSError(domain: "HTTPError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "HTTP Error \(httpResponse.statusCode)"])
                    deferred.resolver.reject(error)
                }
            } else {
                print("❌ [BROKEN LINKS API] Invalid response")
                let error = NSError(domain: "NetworkError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
                deferred.resolver.reject(error)
            }
        }.resume()
        
        return deferred.promise
    }
    
    private func blockUserAPI(myId: String, userToBlockId: String) -> Promise<Void> {
        return Promise { seal in
            let url = "\(APIKeys.BASE_API_URL)/profile/\(userToBlockId)/block"
            
            var request = URLRequest(url: URL(string: url)!)
            request.httpMethod = "POST"
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            
            // Add authorization header
            let token = DatabaseService.singleton.getProfile().token
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            // Add empty body for consistency
            request.httpBody = "".data(using: .utf8)
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                DispatchQueue.main.async {
                    if let error = error {
                        print("Block API Error: \(error)")
                        seal.reject(error)
                        return
                    }
                    
                    if let httpResponse = response as? HTTPURLResponse {
                        print("Block API Response Code: \(httpResponse.statusCode)")
                        if let data = data, let responseString = String(data: data, encoding: .utf8) {
                            print("Block API Response Body: \(responseString)")
                        }
                        
                        if httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 {
                            seal.fulfill(())
                        } else {
                            let errorMessage = "Failed to block user (HTTP \(httpResponse.statusCode))"
                            seal.reject(NSError(domain: "BlockUserError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage]))
                        }
                    } else {
                        seal.reject(NSError(domain: "BlockUserError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No HTTP response"]))
                    }
                }
            }
            task.resume()
        }
    }
    
    private func reportUserAPI(myId: String, reportedUserId: String, reason: String) -> Promise<Void> {
        return Promise { seal in
            let url = "\(APIKeys.BASE_API_URL)/profile/\(reportedUserId)/report"
            
            var request = URLRequest(url: URL(string: url)!)
            request.httpMethod = "POST"
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            
            // Add authorization header
            let token = DatabaseService.singleton.getProfile().token
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            // Add request body as form data
            let bodyString = "reason_category=\(reason.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
            request.httpBody = bodyString.data(using: .utf8)
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                DispatchQueue.main.async {
                    if let error = error {
                        print("Report API Error: \(error)")
                        seal.reject(error)
                        return
                    }
                    
                    if let httpResponse = response as? HTTPURLResponse {
                        print("Report API Response Code: \(httpResponse.statusCode)")
                        if let data = data, let responseString = String(data: data, encoding: .utf8) {
                            print("Report API Response Body: \(responseString)")
                        }
                        
                        if httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 {
                            seal.fulfill(())
                        } else {
                            let errorMessage = "Failed to report user (HTTP \(httpResponse.statusCode))"
                            seal.reject(NSError(domain: "ReportUserError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage]))
                        }
                    } else {
                        seal.reject(NSError(domain: "ReportUserError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No HTTP response"]))
                    }
                }
            }
            task.resume()
        }
    }
}
