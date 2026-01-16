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
        
        // Load like state for this attribute
        loadAttributeLikeState()
    }
    
    func configureForProfile(_ profileId: String) {
        print("ProfileCell configureForProfile called with profileId: \(profileId)")
        currentProfileId = profileId
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
        guard !currentProfileId.isEmpty && !currentAttribute.isEmpty else { return }
        
        // TODO: Load from API - for now set defaults
        setAttributeLikeUI(liked: false, count: 0, isEnabled: true)
    }
}
