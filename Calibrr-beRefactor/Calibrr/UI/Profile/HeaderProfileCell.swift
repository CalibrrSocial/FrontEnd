//
//  HeaderProfileCell.swift
//  Calibrr
//
//  Created by ZVN20210023 on 06/09/2022.
//  Copyright © 2022 Calibrr. All rights reserved.
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

	var onToggleLike: (() -> Void)?
	var onOpenLikes: (() -> Void)?
	var onBlockUser: (() -> Void)?
	var onReportUser: (() -> Void)?

	private var isLikeEnabled: Bool = true
	private var isLiked: Bool = false {
		didSet { updateHeartAppearance() }
	}
	private var likesCount: Int = 0 {
		didSet { likeCountLabel.text = "\(likesCount)" }
	}
    
    override func awakeFromNib() {
        super.awakeFromNib()
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
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
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
		// ENSURE INSTANT UI UPDATES WITH NO ANIMATIONS
		CATransaction.begin()
		CATransaction.setDisableActions(true)
		
		self.isLiked = liked
		self.likesCount = count
		self.isLikeEnabled = isEnabled
		heartButton.isEnabled = isEnabled
		
		CATransaction.commit()
	}

	func currentLikeState() -> Bool { return isLiked }
	func currentLikesCount() -> Int { return likesCount }
	
	func hideBlockReportButtons() {
		blockButton.isHidden = true
		reportButton.isHidden = true
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
		
		// DISABLE ALL BUTTON HIGHLIGHTING AND ANIMATIONS
		heartButton.adjustsImageWhenHighlighted = false
		heartButton.adjustsImageWhenDisabled = false
		heartButton.showsTouchWhenHighlighted = false

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

		// Container stack (to the right of the user's name)
		// Order: Block, Report, Heart, Count, List
		let stack = UIStackView(arrangedSubviews: [blockButton, reportButton, heartButton, likeCountLabel, listButton])
		stack.axis = .horizontal
		stack.alignment = .center
		stack.spacing = 8
		stack.translatesAutoresizingMaskIntoConstraints = false

		contentView.addSubview(stack)

		// Position stack next to the user's name label on the right side
		NSLayoutConstraint.activate([
			stack.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
			stack.leadingAnchor.constraint(greaterThanOrEqualTo: nameLabel.trailingAnchor, constant: 8),
			stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
		])
	}

	private func updateHeartAppearance() {
		// NO ANIMATIONS, NO PULSE, JUST INSTANT CHANGE
		// DISABLE ALL LAYER ANIMATIONS FOR INSTANT UPDATES
		CATransaction.begin()
		CATransaction.setDisableActions(true)
		
		let filled = UIImage(systemName: "heart.fill")?.withRenderingMode(.alwaysTemplate)
		let outline = UIImage(systemName: "heart")?.withRenderingMode(.alwaysTemplate)
		
		if isLiked {
			// RED FILLED HEART - INSTANT
			self.heartButton.setImage(filled, for: .normal)
			self.heartButton.tintColor = .systemRed
		} else {
			// GRAY OUTLINE HEART (NOT FILLED) - INSTANT
			self.heartButton.setImage(outline, for: .normal)
			self.heartButton.tintColor = .tertiaryLabel
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
	}

	@objc private func didTapBlock() {
		onBlockUser?()
	}

	@objc private func didTapReport() {
		onReportUser?()
	}
    
}
