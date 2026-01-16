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
        
        // With the new AttributeLikeManager, we can be less aggressive about refreshing
        // since the cache is more intelligent and API calls are rate-limited
        for indexPath in visibleIndexPaths {
            if let cell = personalInfoTableView.cellForRow(at: indexPath) as? ProfileCell {
                if let profileId = self.profile?.id {
                    // No delay needed - the AttributeLikeManager handles rate limiting
                    cell.configureForProfile(profileId)
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
        
        let targetId = profile.id
        
        // Get current state
        let currentLiked = cell.currentAttributeLikeState()
        let currentCount = cell.currentAttributeLikesCount()
        print("🔥 ProfilePage currentLiked: \(currentLiked), currentCount: \(currentCount)")
        
        // Get attribute info from cell
        print("🔥 Getting attribute info - category: \(cell.attributeCategory ?? "nil"), name: \(cell.attributeName ?? "nil")")
        guard let attributeCategory = cell.attributeCategory,
              let attributeName = cell.attributeName else {
            print("🔥 Missing attribute info, cannot proceed with attribute like")
            return
        }
        print("🔥 Using attribute like system - category: \(attributeCategory), name: \(attributeName)")
        
        // Immediate optimistic UI update
        let newLikedState = !currentLiked
        let newCount = max(0, newLikedState ? currentCount + 1 : currentCount - 1)
        
        // Update local cache for immediate UI feedback
        AttributeLikeManager.shared.updateLocalCache(
            profileId: targetId,
            category: attributeCategory,
            attribute: attributeName,
            liked: newLikedState,
            count: newCount
        )
        
        // Update UI immediately
        cell.setAttributeLikeUI(liked: newLikedState, count: newCount, isEnabled: true)
        
        // Queue the API request through the rate-limited manager
        AttributeLikeManager.shared.queueAttributeLikeOperation(
            profileId: targetId,
            category: attributeCategory,
            attribute: attributeName,
            isLike: newLikedState
        ) { [weak self, weak cell] (finalLiked: Bool, finalCount: Int?) in
            // Update UI with final server state when request completes
            DispatchQueue.main.async {
                if let finalCount = finalCount {
                    cell?.setAttributeLikeUI(liked: finalLiked, count: finalCount, isEnabled: true)
                }
                
                // If liking own profile, refresh profile data to ensure persistence
                let myId = DatabaseService.singleton.getProfile().user.id
                if targetId == myId && finalLiked == true {
                    ProfileAPI.getUser(id: myId).done { [weak self] updated in
                        // Update cached profile data
                        DatabaseService.singleton.updateAccount(updated)
                        self?.profile = updated
                    }.catch { error in
                        print("🔥 ProfilePage Failed to refresh own profile after attribute like: \(error)")
                    }
                }
            }
        }
        
        print("🔥 ProfilePage: Queued attribute like operation through AttributeLikeManager")
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

// MARK: - AttributeLikeManager (Temporary inline implementation)

struct AttributeLikeRequest {
    let id: String
    let profileId: String
    let category: String
    let attribute: String
    let isLike: Bool // true for like, false for unlike
    let completion: ((Bool, Int?) -> Void)?
    let timestamp: Date
    
    init(profileId: String, category: String, attribute: String, isLike: Bool, completion: ((Bool, Int?) -> Void)? = nil) {
        self.id = "\(profileId)|\(category)|\(attribute)"
        self.profileId = profileId
        self.category = category
        self.attribute = attribute
        self.isLike = isLike
        self.completion = completion
        self.timestamp = Date()
    }
}

class AttributeLikeManager {
    static let shared = AttributeLikeManager()
    
    private init() {
        setupRequestProcessor()
    }
    
    // MARK: - Properties
    private var requestQueue: [AttributeLikeRequest] = []
    private var processingQueue = DispatchQueue(label: "com.calibrr.attributelike", qos: .userInitiated)
    private var isProcessing = false
    private var lastRequestTime = Date.distantPast
    
    // Rate limiting configuration
    private let maxRequestsPerMinute = 45 // Stay well under the 60/minute API limit
    private let minRequestInterval: TimeInterval = 60.0 / 45.0 // ~1.33 seconds between requests
    private let maxRetries = 3
    private let baseRetryDelay: TimeInterval = 2.0
    
    // Local state cache for immediate UI updates
    private var localStateCache: [String: (liked: Bool, count: Int, timestamp: Date)] = [:]
    private let cacheExpiration: TimeInterval = 300.0 // 5 minutes
    
    // MARK: - Public Interface
    
    /// Queue an attribute like/unlike operation
    func queueAttributeLikeOperation(
        profileId: String,
        category: String,
        attribute: String,
        isLike: Bool,
        completion: ((Bool, Int?) -> Void)? = nil
    ) {
        let request = AttributeLikeRequest(
            profileId: profileId,
            category: category,
            attribute: attribute,
            isLike: isLike,
            completion: completion
        )
        
        processingQueue.async { [weak self] in
            self?.addToQueue(request)
        }
    }
    
    /// Get cached like state for immediate UI updates
    func getCachedLikeState(profileId: String, category: String, attribute: String) -> (liked: Bool, count: Int)? {
        let key = "\(profileId)|\(category)|\(attribute)"
        
        if let cached = localStateCache[key] {
            let age = Date().timeIntervalSince(cached.timestamp)
            if age < cacheExpiration {
                return (cached.liked, cached.count)
            }
        }
        
        return nil
    }
    
    /// Update local cache for immediate UI feedback
    func updateLocalCache(profileId: String, category: String, attribute: String, liked: Bool, count: Int) {
        let key = "\(profileId)|\(category)|\(attribute)"
        localStateCache[key] = (liked: liked, count: count, timestamp: Date())
    }
    
    /// Clear cache for a specific attribute
    func clearCache(profileId: String, category: String, attribute: String) {
        let key = "\(profileId)|\(category)|\(attribute)"
        localStateCache.removeValue(forKey: key)
    }
    
    // MARK: - Private Implementation
    
    private func addToQueue(_ request: AttributeLikeRequest) {
        // Remove any existing requests for the same attribute to avoid conflicts
        requestQueue.removeAll { $0.id == request.id }
        
        // Add the new request
        requestQueue.append(request)
        
        print("🔥 AttributeLikeManager: Queued request for \(request.id), isLike: \(request.isLike), queue size: \(requestQueue.count)")
        
        // Start processing if not already running
        if !isProcessing {
            processNextRequest()
        }
    }
    
    private func setupRequestProcessor() {
        // Clean up expired cache entries periodically
        Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { [weak self] _ in
            self?.cleanupExpiredCache()
        }
    }
    
    private func cleanupExpiredCache() {
        let now = Date()
        localStateCache = localStateCache.filter { _, value in
            now.timeIntervalSince(value.timestamp) < cacheExpiration
        }
    }
    
    private func processNextRequest() {
        processingQueue.async { [weak self] in
            guard let self = self else { return }
            
            guard !self.requestQueue.isEmpty else {
                self.isProcessing = false
                return
            }
            
            self.isProcessing = true
            let request = self.requestQueue.removeFirst()
            
            // Calculate delay needed to respect rate limiting
            let timeSinceLastRequest = Date().timeIntervalSince(self.lastRequestTime)
            let requiredDelay = max(0, self.minRequestInterval - timeSinceLastRequest)
            
            if requiredDelay > 0 {
                print("🔥 AttributeLikeManager: Delaying request by \(requiredDelay)s for rate limiting")
                DispatchQueue.main.asyncAfter(deadline: .now() + requiredDelay) {
                    self.executeRequest(request)
                }
            } else {
                DispatchQueue.main.async {
                    self.executeRequest(request)
                }
            }
        }
    }
    
    private func executeRequest(_ request: AttributeLikeRequest, retryCount: Int = 0) {
        lastRequestTime = Date()
        
        print("🔥 AttributeLikeManager: Executing request for \(request.id), isLike: \(request.isLike), retry: \(retryCount)")
        
        let myId = DatabaseService.singleton.getProfile().user.id
        let endpoint = "https://api.calibrr.com/api/profile/\(myId)/attributes/like"
        
        guard let url = URL(string: endpoint) else {
            print("🔥 AttributeLikeManager: Failed to create URL")
            handleRequestFailure(request, retryCount: retryCount)
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.isLike ? "POST" : "DELETE"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add authorization header
        let token = DatabaseService.singleton.getProfile().token
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        // Add request body
        let body: [String: Any] = [
            "profileId": request.profileId,
            "category": request.category,
            "attribute": request.attribute
        ]
        
        do {
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            print("🔥 AttributeLikeManager: JSON serialization failed: \(error)")
            handleRequestFailure(request, retryCount: retryCount)
            return
        }
        
        // Execute the request
        URLSession.shared.dataTask(with: urlRequest) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.handleRequestResponse(request, data: data, response: response, error: error, retryCount: retryCount)
            }
        }.resume()
    }
    
    private func handleRequestResponse(
        _ request: AttributeLikeRequest,
        data: Data?,
        response: URLResponse?,
        error: Error?,
        retryCount: Int
    ) {
        if let error = error {
            print("🔥 AttributeLikeManager: Request failed with error: \(error)")
            handleRequestFailure(request, retryCount: retryCount)
            return
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            print("🔥 AttributeLikeManager: Invalid response type")
            handleRequestFailure(request, retryCount: retryCount)
            return
        }
        
        print("🔥 AttributeLikeManager: Response status: \(httpResponse.statusCode)")
        
        if httpResponse.statusCode == 429 {
            // Rate limited - retry with exponential backoff
            print("🔥 AttributeLikeManager: Rate limited, will retry")
            handleRequestFailure(request, retryCount: retryCount, isRateLimit: true)
            return
        }
        
        if httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 {
            // Success
            print("🔥 AttributeLikeManager: Request succeeded for \(request.id)")
            
            // Update local cache with the new state
            if let cached = getCachedLikeState(profileId: request.profileId, category: request.category, attribute: request.attribute) {
                let newCount = request.isLike ? cached.count + 1 : max(0, cached.count - 1)
                updateLocalCache(profileId: request.profileId, category: request.category, attribute: request.attribute, liked: request.isLike, count: newCount)
                
                // Notify completion
                request.completion?(request.isLike, newCount)
            } else {
                // Fetch fresh data if no cache available
                fetchAttributeLikeState(request.profileId, request.category, request.attribute) { [weak self] liked, count in
                    self?.updateLocalCache(profileId: request.profileId, category: request.category, attribute: request.attribute, liked: liked, count: count)
                    request.completion?(liked, count)
                }
            }
            
            // Process next request
            processingQueue.async { [weak self] in
                self?.processNextRequest()
            }
        } else {
            print("🔥 AttributeLikeManager: Request failed with status: \(httpResponse.statusCode)")
            handleRequestFailure(request, retryCount: retryCount)
        }
    }
    
    private func handleRequestFailure(_ request: AttributeLikeRequest, retryCount: Int, isRateLimit: Bool = false) {
        if retryCount < maxRetries {
            let delay = isRateLimit ? baseRetryDelay * 2 : baseRetryDelay * pow(2.0, Double(retryCount))
            print("🔥 AttributeLikeManager: Retrying request in \(delay)s (attempt \(retryCount + 1)/\(maxRetries))")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                self?.executeRequest(request, retryCount: retryCount + 1)
            }
        } else {
            print("🔥 AttributeLikeManager: Request failed after \(maxRetries) retries")
            
            // Revert local cache to previous state
            if let cached = getCachedLikeState(profileId: request.profileId, category: request.category, attribute: request.attribute) {
                let revertedLiked = !request.isLike
                let revertedCount = request.isLike ? max(0, cached.count - 1) : cached.count + 1
                updateLocalCache(profileId: request.profileId, category: request.category, attribute: request.attribute, liked: revertedLiked, count: revertedCount)
                
                request.completion?(revertedLiked, revertedCount)
            }
            
            // Process next request
            processingQueue.async { [weak self] in
                self?.processNextRequest()
            }
        }
    }
    
    private func fetchAttributeLikeState(
        _ profileId: String,
        _ category: String,
        _ attribute: String,
        completion: @escaping (Bool, Int) -> Void
    ) {
        let encodedCategory = category.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? category
        let encodedAttribute = attribute.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? attribute
        let endpoint = "https://api.calibrr.com/api/profile/\(profileId)/attributes/\(encodedCategory)/\(encodedAttribute)/likes"
        
        guard let url = URL(string: endpoint) else {
            completion(false, 0)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let token = DatabaseService.singleton.getProfile().token
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                guard let data = data,
                      let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200,
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    completion(false, 0)
                    return
                }
                
                let totalLikes = json["total_likes"] as? Int ?? 0
                let isLikedByMe = json["liked_by_user"] as? Bool ?? false
                completion(isLikedByMe, totalLikes)
            }
        }.resume()
    }
}
