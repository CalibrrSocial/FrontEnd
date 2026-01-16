//
//  ProfileCell.swift
//  Calibrr
//
//  Created by ZVN20210023 on 02/09/2022.
//  Copyright © 2022 Calibrr. All rights reserved.
//

import UIKit
import OpenAPIClient

class ProfileCell: ACell<(String, String, Bool)> {
    @IBOutlet weak var dividerView: UIView!
    @IBOutlet weak var desLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    // Static cache for attribute like states to prevent duplicate API calls across cells
    private static var attributeLikeCache: [String: (liked: Bool, count: Int, timestamp: Date)] = [:]
    private static let cacheExpiration: TimeInterval = 30.0 // Cache for 30 seconds
    
    // MARK: - Attribute Likes UI
    private var heartButton: UIButton = UIButton(type: .system)
    private var likeCountLabel: UILabel = UILabel()
    private var likesStack: UIStackView = UIStackView()
    
    var onToggleAttributeLike: (() -> Void)?
    
    private var isLikeEnabled: Bool = true
    private var isLiked: Bool = false {
        didSet { updateHeartAppearance() }
    }
    private var likesCount: Int = 0 {
        didSet { likeCountLabel.text = "\(likesCount)" }
    }
    
    private var currentCategory: String = ""
    private var currentAttribute: String = ""
    private var currentProfileId: String = ""
    private var isLoadingLikeState: Bool = false
    private var retryCount: Int = 0
    private let maxRetries: Int = 3
    private var lastLoadTime: Date = Date.distantPast
    private let minLoadInterval: TimeInterval = 1.0 // Minimum 1 second between loads
    private var currentDataTask: URLSessionDataTask?
    
    // Track the last loaded configuration to prevent duplicate requests
    private var lastLoadedConfig: String = ""
    
    // Public properties for ProfilePage access
    var attributeCategory: String? { return currentCategory.isEmpty ? nil : currentCategory }
    var attributeName: String? { return currentAttribute.isEmpty ? nil : currentAttribute }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupAttributeLikeUI()
        
        // Ensure cell is properly configured for interaction
        self.selectionStyle = .none
        self.contentView.isUserInteractionEnabled = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // Cancel any ongoing network request
        currentDataTask?.cancel()
        currentDataTask = nil
        
        // Reset state
        isLoadingLikeState = false
        retryCount = 0
        isLiked = false
        likesCount = 0
        isLikeEnabled = true
        
        // Clear data
        currentCategory = ""
        currentAttribute = ""
        currentProfileId = ""
        lastLoadedConfig = ""
        
        // Reset UI
        desLabel.text = ""
        titleLabel.text = ""
        updateHeartAppearance()
    }
    
    override func setup(_ indexPath: IndexPath, _ item: (String, String, Bool)) {
        dividerView.isHidden = item.2
        desLabel.text = item.1
        titleLabel.text = item.0
        
        // Parse category and attribute from title
        currentCategory = getCategoryFromTitle(item.0)
        currentAttribute = item.1
        print("🔥 ProfileCell setup - category: '\(currentCategory)', attribute: '\(currentAttribute)', title: '\(item.0)'")
        
        // Setup complete
        
        // Don't load like state here - wait for configureForProfile to be called with profileId
        // This prevents unnecessary API calls with missing profileId
    }
    
    func configureForProfile(_ profileId: String) {
        
        let now = Date()
        let timeSinceLastLoad = now.timeIntervalSince(lastLoadTime)
        
        // Only reload if profileId has changed OR enough time has passed
        if currentProfileId != profileId {
            currentProfileId = profileId
            retryCount = 0 // Reset retry count for new profile
            lastLoadTime = now
            loadAttributeLikeState()
        } else if timeSinceLastLoad >= minLoadInterval {
            retryCount = 0 // Reset retry count for refresh
            lastLoadTime = now
            loadAttributeLikeState()
        }
    }
    
    func forceRefreshLikeState() {
        // Force refresh regardless of throttling - used after like actions
        retryCount = 0
        lastLoadTime = Date()
        
        // Invalidate cache for this configuration
        let currentConfig = "\(currentProfileId)|\(currentCategory)|\(currentAttribute)"
        ProfileCell.attributeLikeCache.removeValue(forKey: currentConfig)
        
        loadAttributeLikeState()
    }
    
    private func setupAttributeLikeUI() {
        // Heart button
        heartButton.tintColor = .tertiaryLabel
        heartButton.addTarget(self, action: #selector(didTapAttributeHeart), for: .touchUpInside)
        heartButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        heartButton.setContentHuggingPriority(.required, for: .horizontal)
        heartButton.isUserInteractionEnabled = true  // Ensure interaction is enabled
        
        // Enable visual feedback for debugging
        heartButton.showsTouchWhenHighlighted = true  // Show touch feedback
        heartButton.adjustsImageWhenHighlighted = true  // Visual feedback on tap
        
        // Count label
        likeCountLabel.textColor = .label
        likeCountLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        likeCountLabel.text = "0"
        likeCountLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        likeCountLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        // Stack view
        likesStack = UIStackView(arrangedSubviews: [heartButton, likeCountLabel])
        likesStack.axis = .horizontal
        likesStack.alignment = .center
        likesStack.spacing = 2
        likesStack.translatesAutoresizingMaskIntoConstraints = false
        likesStack.isUserInteractionEnabled = true  // Ensure stack allows interaction
        
        contentView.addSubview(likesStack)
        contentView.bringSubviewToFront(likesStack)  // Bring to front to avoid being covered
        
        // Initial appearance
        updateHeartAppearance()
        
        let leadingConstraint = likesStack.leadingAnchor.constraint(greaterThanOrEqualTo: desLabel.trailingAnchor, constant: 8)
        leadingConstraint.priority = UILayoutPriority(999)
        
        NSLayoutConstraint.activate([
            likesStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            likesStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            leadingConstraint
        ])
    }
    
    private func updateHeartAppearance() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        CATransaction.setAnimationDuration(0.0)
        
        UIView.performWithoutAnimation {
            let filled = UIImage(systemName: "heart.fill")?.withRenderingMode(.alwaysTemplate)
            let outline = UIImage(systemName: "heart")?.withRenderingMode(.alwaysTemplate)
            
            if isLiked {
                self.heartButton.setImage(filled, for: .normal)
                self.heartButton.tintColor = .systemRed
            } else {
                self.heartButton.setImage(outline, for: .normal)
                self.heartButton.tintColor = .tertiaryLabel
            }
            
            self.heartButton.layoutIfNeeded()
        }
        
        CATransaction.commit()
    }
    
    @objc private func didTapAttributeHeart() {
        print("🔥 ATTRIBUTE HEART TAPPED - isLikeEnabled: \(isLikeEnabled)")
        print("🔥 onToggleAttributeLike callback exists: \(onToggleAttributeLike != nil)")
        guard isLikeEnabled else { 
            print("🔥 Like is disabled, returning")
            return 
        }
        print("🔥 Calling onToggleAttributeLike callback")
        onToggleAttributeLike?()
    }
    
    func setAttributeLikeUI(liked: Bool, count: Int, isEnabled: Bool) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        CATransaction.setAnimationDuration(0.0)
        
        UIView.performWithoutAnimation {
            self.isLiked = liked
            self.likesCount = count
            self.isLikeEnabled = isEnabled
            self.heartButton.isEnabled = isEnabled
            
            self.heartButton.layoutIfNeeded()
            self.likeCountLabel.layoutIfNeeded()
        }
        
        CATransaction.commit()
    }
    
    func currentAttributeLikeState() -> Bool { return isLiked }
    func currentAttributeLikesCount() -> Int { return likesCount }
    
    private func getCategoryFromTitle(_ title: String) -> String {
        // Map display titles to categories
        let categoryMap: [String: String] = [
            "Born:": "Personal",
            "Currently lives in:": "Location",
            "Hometown:": "Location", 
            "Past High School, Graduated from:": "Education",
            "Current College/School:": "Education",
            "Major/Studying:": "Education",
            "Class/Graduation Year:": "Education",
            "Current Campus:": "Education",
            "Career Aspirations:": "Career",
            "Postgraduate Plans:": "Career",
            "In Courses:": "Education",
            "Greek life:": "Social",
            "Team/Club:": "Social",
            "Best Friends:": "Social",
            "Politics:": "Politics",
            "Favorite Music:": "Music",
            "Favorite TV:": "Entertainment",
            "Favorite Games:": "Entertainment",
            "Religion:": "Religion",
            "Occupation:": "Career",
            "Gender:": "Personal",
            "Sexuality:": "Personal",
            "Relationship:": "Personal",
            "Bio:": "Personal"
        ]
        
        return categoryMap[title] ?? "Other"
    }
    
    private func loadAttributeLikeState() {
        print("🔥 ProfileCell loadAttributeLikeState called - profileId: '\(currentProfileId)', category: '\(currentCategory)', attribute: '\(currentAttribute)'")
        guard !currentProfileId.isEmpty && !currentAttribute.isEmpty && !currentCategory.isEmpty else { 
            print("🔥 ProfileCell loadAttributeLikeState: Missing required data")
            return 
        }
        
        // Create a unique configuration string
        let currentConfig = "\(currentProfileId)|\(currentCategory)|\(currentAttribute)"
        
        // Check cache first
        if let cached = ProfileCell.attributeLikeCache[currentConfig] {
            let age = Date().timeIntervalSince(cached.timestamp)
            if age < ProfileCell.cacheExpiration {
                print("🔥 ProfileCell loadAttributeLikeState: Using cached data (age: \(Int(age))s)")
                setAttributeLikeUI(liked: cached.liked, count: cached.count, isEnabled: true)
                lastLoadedConfig = currentConfig
                return
            }
        }
        
        // Check if we've already loaded this exact configuration
        if currentConfig == lastLoadedConfig && isLoadingLikeState {
            print("🔥 ProfileCell loadAttributeLikeState: Already loading this exact configuration, skipping")
            return
        }
        
        // Prevent duplicate concurrent requests
        guard !isLoadingLikeState else {
            print("🔥 ProfileCell loadAttributeLikeState: Already loading, skipping duplicate request")
            return
        }
        
        // Check retry limit
        guard retryCount < maxRetries else {
            setAttributeLikeUI(liked: false, count: 0, isEnabled: true)
            return
        }
        
        isLoadingLikeState = true
        lastLoadedConfig = currentConfig
        
        // Load attribute like state from API
        let myId = DatabaseService.singleton.getProfile().user.id
        let encodedCategory = currentCategory.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? currentCategory
        let encodedAttribute = currentAttribute.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? currentAttribute
        let endpoint = "https://api.calibrr.com/api/profile/\(currentProfileId)/attributes/\(encodedCategory)/\(encodedAttribute)/likes"
        print("🔥 ProfileCell loadAttributeLikeState making API call to: \(endpoint)")
        
        guard let url = URL(string: endpoint) else {
            isLoadingLikeState = false
            setAttributeLikeUI(liked: false, count: 0, isEnabled: true)
            return
        }
        
        // Prepare headers
        var headers: [String: String] = [:]
        let token = DatabaseService.singleton.getProfile().token
        headers["Authorization"] = "Bearer \(token)"
        
        // Create the request
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        // Check if we're already loading this exact configuration
        if let existingTask = currentDataTask {
            print("🔥 ProfileCell loadAttributeLikeState: Cancelling existing task")
            existingTask.cancel()
        }
        
        // Make the API call
        currentDataTask = URLSession.shared.dataTask(with: request) { [weak self, currentConfig] data, response, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                self.isLoadingLikeState = false
                self.currentDataTask = nil
                
                if let error = error as NSError? {
                    print("🔥 ProfileCell loadAttributeLikeState error: \(error)")
                    
                    // Handle cancellation
                    if error.code == NSURLErrorCancelled {
                        return
                    }
                    
                    // For other errors, show cached or default state
                    if let cached = ProfileCell.attributeLikeCache[currentConfig] {
                        self.setAttributeLikeUI(liked: cached.liked, count: cached.count, isEnabled: true)
                    } else {
                        self.setAttributeLikeUI(liked: false, count: 0, isEnabled: true)
                    }
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    print("🔥 ProfileCell loadAttributeLikeState response status: \(httpResponse.statusCode)")
                    
                    if httpResponse.statusCode == 429 {
                        // Rate limited - use cached data if available
                        if let cached = ProfileCell.attributeLikeCache[currentConfig] {
                            self.setAttributeLikeUI(liked: cached.liked, count: cached.count, isEnabled: true)
                        } else {
                            self.setAttributeLikeUI(liked: false, count: 0, isEnabled: true)
                        }
                        return
                    }
                    
                    guard httpResponse.statusCode == 200, let data = data else {
                        print("🔥 ProfileCell loadAttributeLikeState unexpected status: \(httpResponse.statusCode)")
                        // Use cached data if available
                        if let cached = ProfileCell.attributeLikeCache[currentConfig] {
                            self.setAttributeLikeUI(liked: cached.liked, count: cached.count, isEnabled: true)
                        } else {
                            self.setAttributeLikeUI(liked: false, count: 0, isEnabled: true)
                        }
                        return
                    }
                    
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                            let totalLikes = json["total_likes"] as? Int ?? 0
                            let isLikedByMe = json["liked_by_user"] as? Bool ?? false
                            print("🔥 ProfileCell loadAttributeLikeState success - liked: \(isLikedByMe), count: \(totalLikes)")

                            self.retryCount = 0 // Reset retry count on success
                            self.setAttributeLikeUI(liked: isLikedByMe, count: totalLikes, isEnabled: true)
                            
                            // Update cache
                            ProfileCell.attributeLikeCache[currentConfig] = (
                                liked: isLikedByMe,
                                count: totalLikes,
                                timestamp: Date()
                            )
                        }
                    } catch {
                        print("🔥 ProfileCell loadAttributeLikeState JSON parse error: \(error)")
                        self.setAttributeLikeUI(liked: false, count: 0, isEnabled: true)
                    }
                }
            }
        }
        
        currentDataTask?.resume()
    }
}
