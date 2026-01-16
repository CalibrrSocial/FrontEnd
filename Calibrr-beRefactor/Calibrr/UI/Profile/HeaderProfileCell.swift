//
//  HeaderProfileCell.swift
//  Calibrr
//
//
//  Copyright © Calibrr. All rights reserved.
//

import UIKit
import OpenAPIClient
import SDWebImage

class HeaderProfileCell: UITableViewCell {

    @IBOutlet weak var avatarView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var coverImageView: UIImageView!

	// MARK: - Likes UI
	private var heartButton: UIButton = UIButton(type: .system)
	private var likeCountLabel: UILabel = UILabel()
	private var listButton: UIButton = UIButton(type: .system)

	// MARK: - Block/Report UI
	private var blockButton: UIButton = UIButton(type: .system)
	private var reportButton: UIButton = UIButton(type: .system)
	private var reportLinkButton: UIButton = UIButton(type: .system)

	var onToggleLike: (() -> Void)?
	var onOpenLikes: (() -> Void)?
	var onBlockUser: (() -> Void)?
	var onReportUser: (() -> Void)?
	var onReportBrokenLink: (() -> Void)?

	private var isLikeEnabled: Bool = true
	private var isLiked: Bool = false {
		didSet { updateHeartAppearance() }
	}
	private var likesCount: Int = 0 {
		didSet { likeCountLabel.text = "\(likesCount)" }
	}
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // DISABLE ALL POSSIBLE CELL ANIMATIONS
        self.layer.allowsGroupOpacity = false
        self.layer.shouldRasterize = false
        self.contentView.layer.allowsGroupOpacity = false
        self.contentView.layer.shouldRasterize = false
        
        self.setupView()
    }
    
    private func setupView() {
        self.avatarView.roundFull()
        self.avatarImageView.roundFull()
        nameLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        nameLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)

		// Configure action buttons UI (programmatically to avoid XIB changes)
		setupActionButtons()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        // NEVER ANIMATE SELECTION - ALWAYS INSTANT
        super.setSelected(selected, animated: false)
        
        // NO SELECTION STATE CHANGES
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        // NEVER ANIMATE HIGHLIGHTING - ALWAYS INSTANT
        super.setHighlighted(highlighted, animated: false)
    }
    
    func configureCell(_ profile: User) {
    
        if let image = profile.pictureCover,
            let url = URL(string: image) {
            coverImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "background"))
        } else {
            coverImageView.image = UIImage(named: "background")
        }
        
        if let image = profile.pictureProfile, let url = URL(string: image) {
            avatarImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "icon_avatar_placeholder"), context: nil)
        } else {
            avatarImageView.image = UIImage(named: "icon_avatar_placeholder")
        }
        
        nameLabel.text = "\(profile.firstName) \(profile.lastName)"
    }

	// MARK: - Public API
	func setLikeUI(liked: Bool, count: Int, isEnabled: Bool) {
		// ABSOLUTELY INSTANT UI UPDATES - NO ANIMATIONS WHATSOEVER
		CATransaction.begin()
		CATransaction.setDisableActions(true)
		CATransaction.setAnimationDuration(0.0)
		
		// REMOVE ANY EXISTING ANIMATIONS
		heartButton.layer.removeAllAnimations()
		heartButton.imageView?.layer.removeAllAnimations()
		likeCountLabel.layer.removeAllAnimations()
		
		// UPDATE STATE INSIDE PERFORMWITHOUTANIMATION BLOCK
		UIView.performWithoutAnimation {
			self.isLiked = liked
			self.likesCount = count
			self.isLikeEnabled = isEnabled
			self.heartButton.isEnabled = isEnabled
			
			// FORCE IMMEDIATE LAYOUT
			self.heartButton.layoutIfNeeded()
			self.likeCountLabel.layoutIfNeeded()
		}
		
		CATransaction.commit()
	}

	func currentLikeState() -> Bool { return isLiked }
	func currentLikesCount() -> Int { return likesCount }
	
	func hideBlockReportButtons() {
		blockButton.isHidden = true
		reportButton.isHidden = true
		reportLinkButton.isHidden = true
	}

	// MARK: - Private helpers
	private func setupActionButtons() {
		// Setup Block and Report buttons first
		setupBlockReportButtons()
		
		// Setup existing likes UI
		// Heart button - starts gray (will be updated based on like state)
		heartButton.tintColor = .tertiaryLabel
		heartButton.addTarget(self, action: #selector(didTapHeart), for: .touchUpInside)
		heartButton.setContentCompressionResistancePriority(.required, for: .horizontal)
		heartButton.setContentHuggingPriority(.required, for: .horizontal)
		
		// DISABLE ALL BUTTON HIGHLIGHTING, ANIMATIONS, AND DELAYS
		heartButton.adjustsImageWhenHighlighted = false
		heartButton.adjustsImageWhenDisabled = false
		heartButton.showsTouchWhenHighlighted = false
		
		// DISABLE ALL POSSIBLE ANIMATION SOURCES
		heartButton.layer.allowsGroupOpacity = false
		heartButton.imageView?.layer.allowsGroupOpacity = false
		heartButton.layer.shouldRasterize = false
		heartButton.imageView?.layer.shouldRasterize = false
		
		// ENSURE INSTANT RESPONSE TO TOUCHES
		if let imageView = heartButton.imageView {
			imageView.contentMode = .center
		}

		// Count label
		likeCountLabel.textColor = .label
		likeCountLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
		likeCountLabel.text = "0"
		likeCountLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
		likeCountLabel.setContentHuggingPriority(.required, for: .horizontal)

		// List button (panel trigger)
		listButton.tintColor = .label
		listButton.addTarget(self, action: #selector(didTapList), for: .touchUpInside)
		listButton.setContentCompressionResistancePriority(.required, for: .horizontal)
		listButton.setContentHuggingPriority(.required, for: .horizontal)

		// Images
		updateHeartAppearance()
		let listImage = UIImage(systemName: "line.3.horizontal")?.withRenderingMode(.alwaysTemplate) ?? UIImage()
		listButton.setImage(listImage, for: .normal)

		// Likes stack
		let likesStack = UIStackView(arrangedSubviews: [heartButton, likeCountLabel, listButton])
		likesStack.axis = .horizontal
		likesStack.alignment = .center
		likesStack.spacing = 4
		likesStack.translatesAutoresizingMaskIntoConstraints = false
		likesStack.setContentCompressionResistancePriority(.required, for: .horizontal)
		likesStack.setContentHuggingPriority(.required, for: .horizontal)

		// Right-aligned actions - order: block, report user, report broken link
		let rightStack = UIStackView(arrangedSubviews: [blockButton, reportButton, reportLinkButton])
		rightStack.axis = .horizontal
		rightStack.alignment = .center
		rightStack.spacing = 8
		rightStack.translatesAutoresizingMaskIntoConstraints = false

		contentView.addSubview(rightStack)
		contentView.addSubview(likesStack)

		NSLayoutConstraint.activate([
			// Right stack stays aligned to trailing edge
			rightStack.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
			rightStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

			// Likes stack flush to the right of the name
			likesStack.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
			likesStack.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: 0),
			likesStack.trailingAnchor.constraint(lessThanOrEqualTo: rightStack.leadingAnchor, constant: -8)
		])
	}

	private func updateHeartAppearance() {
		// ABSOLUTELY NO ANIMATIONS WHATSOEVER - COMPLETELY INSTANT
		// DISABLE ALL POSSIBLE ANIMATIONS AT EVERY LEVEL
		CATransaction.begin()
		CATransaction.setDisableActions(true)
		CATransaction.setAnimationDuration(0.0)
		
		// DISABLE ANY IMPLICIT LAYER ANIMATIONS
		heartButton.layer.removeAllAnimations()
		heartButton.imageView?.layer.removeAllAnimations()
		
		// FORCE IMMEDIATE LAYOUT WITHOUT ANIMATIONS
		UIView.performWithoutAnimation {
			let filled = UIImage(systemName: "heart.fill")?.withRenderingMode(.alwaysTemplate)
			let outline = UIImage(systemName: "heart")?.withRenderingMode(.alwaysTemplate)
			
			if isLiked {
				// RED FILLED HEART - ABSOLUTELY INSTANT
				self.heartButton.setImage(filled, for: .normal)
				self.heartButton.tintColor = .systemRed
			} else {
				// GRAY OUTLINE HEART (NOT FILLED) - ABSOLUTELY INSTANT
				self.heartButton.setImage(outline, for: .normal)
				self.heartButton.tintColor = .tertiaryLabel
			}
			
			// FORCE IMMEDIATE LAYOUT UPDATE
			self.heartButton.layoutIfNeeded()
		}
		
		CATransaction.commit()
	}

	@objc private func didTapHeart() {
		guard isLikeEnabled else { return }
		onToggleLike?()
	}

	@objc private func didTapList() {
		onOpenLikes?()
	}

	private func setupBlockReportButtons() {
		// Block button
		blockButton.tintColor = .systemOrange
		blockButton.addTarget(self, action: #selector(didTapBlock), for: .touchUpInside)
		blockButton.setContentCompressionResistancePriority(.required, for: .horizontal)
		blockButton.setContentHuggingPriority(.required, for: .horizontal)
		
		let blockImage = UIImage(systemName: "hand.raised.fill")?.withRenderingMode(.alwaysTemplate) ?? UIImage()
		blockButton.setImage(blockImage, for: .normal)
		
		// Report button
		reportButton.tintColor = .systemRed
		reportButton.addTarget(self, action: #selector(didTapReport), for: .touchUpInside)
		reportButton.setContentCompressionResistancePriority(.required, for: .horizontal)
		reportButton.setContentHuggingPriority(.required, for: .horizontal)
		
		let reportImage = UIImage(systemName: "exclamationmark.triangle.fill")?.withRenderingMode(.alwaysTemplate) ?? UIImage()
		reportButton.setImage(reportImage, for: .normal)
		
		// Report Broken Link button
		reportLinkButton.tintColor = .systemPurple
		reportLinkButton.addTarget(self, action: #selector(didTapReportLink), for: .touchUpInside)
		reportLinkButton.setContentCompressionResistancePriority(.required, for: .horizontal)
		reportLinkButton.setContentHuggingPriority(.required, for: .horizontal)
		
		let linkImage = UIImage(systemName: "link.circle.fill")?.withRenderingMode(.alwaysTemplate) ?? UIImage()
		reportLinkButton.setImage(linkImage, for: .normal)
	}

	@objc private func didTapBlock() {
		onBlockUser?()
	}

	@objc private func didTapReport() {
		onReportUser?()
	}
	
	@objc private func didTapReportLink() {
		onReportBrokenLink?()
	}
    
}
