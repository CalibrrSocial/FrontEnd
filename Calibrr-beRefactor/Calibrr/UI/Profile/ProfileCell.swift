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
    
    override func setup(_ indexPath: IndexPath, _ item: (String, String, Bool)) {
        dividerView.isHidden = item.2
        desLabel.text = item.1
        titleLabel.text = item.0
        
        // Parse category and attribute from title
        currentCategory = getCategoryFromTitle(item.0)
        currentAttribute = item.1
        
        print("ProfileCell setup - category: \(currentCategory), attribute: \(currentAttribute), profileId: \(currentProfileId)")
        
        // Don't load like state here - wait for configureForProfile to be called with profileId
        // This prevents unnecessary API calls with missing profileId
    }
    
    func configureForProfile(_ profileId: String) {
        print("ProfileCell configureForProfile called with profileId: \(profileId)")
        
        // Only reload if profileId has changed to prevent duplicate API calls
        if currentProfileId != profileId {
            currentProfileId = profileId
            loadAttributeLikeState()
        } else {
            print("ProfileCell: Same profileId, skipping duplicate API call")
        }
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
        print("Heart button tapped! isLikeEnabled: \(isLikeEnabled), profileId: \(currentProfileId)")
        guard isLikeEnabled else { 
            print("Like is disabled, returning")
            return 
        }
        if let callback = onToggleAttributeLike {
            print("Calling onToggleAttributeLike callback")
            callback()
        } else {
            print("No onToggleAttributeLike callback set!")
        }
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
        guard !currentProfileId.isEmpty && !currentAttribute.isEmpty && !currentCategory.isEmpty else { 
            print("ProfileCell: Missing required data for loading like state - profileId: \(currentProfileId), attribute: \(currentAttribute), category: \(currentCategory)")
            return 
        }
        
        // Prevent duplicate concurrent requests
        guard !isLoadingLikeState else {
            print("ProfileCell: Already loading like state, skipping duplicate request")
            return
        }
        
        isLoadingLikeState = true
        
        // Load attribute like state from API
        let myId = DatabaseService.singleton.getProfile().user.id
        let encodedCategory = currentCategory.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? currentCategory
        let encodedAttribute = currentAttribute.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? currentAttribute
        let endpoint = "https://api.calibrr.com/api/profile/\(currentProfileId)/attributes/\(encodedCategory)/\(encodedAttribute)/likes"
        
        print("ProfileCell: Loading like state from: \(endpoint)")
        
        guard let url = URL(string: endpoint) else {
            print("ProfileCell: Invalid URL for loading like state")
            isLoadingLikeState = false
            setAttributeLikeUI(liked: false, count: 0, isEnabled: true)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let token = DatabaseService.singleton.getProfile().token
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                self.isLoadingLikeState = false
                
                if let error = error {
                    print("ProfileCell: Error loading like state: \(error)")
                    self.setAttributeLikeUI(liked: false, count: 0, isEnabled: true)
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    print("ProfileCell: Like state API response: \(httpResponse.statusCode)")
                    
                    if httpResponse.statusCode == 200, let data = data {
                        do {
                            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                                let totalLikes = json["total_likes"] as? Int ?? 0
                                let isLikedByMe = json["liked_by_user"] as? Bool ?? false
                                
                                print("ProfileCell: Loaded like state - liked: \(isLikedByMe), count: \(totalLikes)")
                                self.setAttributeLikeUI(liked: isLikedByMe, count: totalLikes, isEnabled: true)
                            }
                        } catch {
                            print("ProfileCell: Error parsing like state response: \(error)")
                            self.setAttributeLikeUI(liked: false, count: 0, isEnabled: true)
                        }
                    } else if httpResponse.statusCode == 429 {
                        print("ProfileCell: Rate limited (429), will retry after delay")
                        // Retry after a short delay for rate limiting
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            self.loadAttributeLikeState()
                        }
                    } else {
                        print("ProfileCell: Non-200 response for like state")
                        self.setAttributeLikeUI(liked: false, count: 0, isEnabled: true)
                    }
                }
            }
        }.resume()
    }
}
