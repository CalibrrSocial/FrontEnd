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

	var onToggleLike: (() -> Void)?
	var onOpenLikes: (() -> Void)?

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

		// Configure likes UI (programmatically to avoid XIB changes)
		setupLikesUI()
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
		self.isLiked = liked
		self.likesCount = count
		self.isLikeEnabled = isEnabled
		heartButton.isEnabled = isEnabled
	}

	func currentLikeState() -> Bool { return isLiked }
	func currentLikesCount() -> Int { return likesCount }

	// MARK: - Private helpers
	private func setupLikesUI() {
		// Heart button - starts gray (will be updated based on like state)
		heartButton.tintColor = .tertiaryLabel
		heartButton.addTarget(self, action: #selector(didTapHeart), for: .touchUpInside)
		heartButton.setContentCompressionResistancePriority(.required, for: .horizontal)
		heartButton.setContentHuggingPriority(.required, for: .horizontal)

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
		let stack = UIStackView(arrangedSubviews: [heartButton, likeCountLabel, listButton])
		stack.axis = .horizontal
		stack.alignment = .center
		stack.spacing = 6
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
		let filled = UIImage(systemName: "heart.fill")?.withRenderingMode(.alwaysTemplate)
		let outline = UIImage(systemName: "heart")?.withRenderingMode(.alwaysTemplate)
		
		if isLiked {
			// RED FILLED HEART
			self.heartButton.setImage(filled, for: .normal)
			self.heartButton.tintColor = .systemRed
		} else {
			// GRAY OUTLINE HEART (NOT FILLED)
			self.heartButton.setImage(outline, for: .normal)
			self.heartButton.tintColor = .tertiaryLabel
		}
	}

	@objc private func didTapHeart() {
		guard isLikeEnabled else { return }
		onToggleLike?()
	}

	@objc private func didTapList() {
		onOpenLikes?()
	}
    
}
