//
//  HeaderProfileCell.swift
//  Calibrr
//
//  Created by ZVN20210023 on 06/09/2022.
//  Copyright © 2022 Calibrr. All rights reserved.
//

import UIKit
import OpenAPIClient

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
		// Heart button
		heartButton.tintColor = .white
		heartButton.addTarget(self, action: #selector(didTapHeart), for: .touchUpInside)
		heartButton.setContentCompressionResistancePriority(.required, for: .horizontal)
		heartButton.setContentHuggingPriority(.required, for: .horizontal)

		// Count label
		likeCountLabel.textColor = .white
		likeCountLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
		likeCountLabel.text = "0"
		likeCountLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
		likeCountLabel.setContentHuggingPriority(.required, for: .horizontal)

		// List button (panel trigger)
		listButton.tintColor = .white
		listButton.addTarget(self, action: #selector(didTapList), for: .touchUpInside)
		listButton.setContentCompressionResistancePriority(.required, for: .horizontal)
		listButton.setContentHuggingPriority(.required, for: .horizontal)

		// Images
		updateHeartAppearance()
		let listImage = UIImage(systemName: "list.bullet")?.withRenderingMode(.alwaysTemplate) ?? UIImage()
		listButton.setImage(listImage, for: .normal)

		// Container stack
		let stack = UIStackView(arrangedSubviews: [heartButton, likeCountLabel, listButton])
		stack.axis = .horizontal
		stack.alignment = .center
		stack.spacing = 8
		stack.translatesAutoresizingMaskIntoConstraints = false

		contentView.addSubview(stack)

		// Place near the bottom-right of the cover image
		NSLayoutConstraint.activate([
			stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
			stack.bottomAnchor.constraint(equalTo: coverImageView.bottomAnchor, constant: -12)
		])
	}

	private func updateHeartAppearance() {
		let filled = UIImage(named: "icon-like-1")?.withRenderingMode(.alwaysTemplate)
		let outline = UIImage(named: "icon-like")?.withRenderingMode(.alwaysTemplate)
		heartButton.setImage(isLiked ? (filled ?? outline) : (outline ?? filled), for: .normal)
	}

	@objc private func didTapHeart() {
		guard isLikeEnabled else { return }
		onToggleLike?()
	}

	@objc private func didTapList() {
		onOpenLikes?()
	}
    
}
