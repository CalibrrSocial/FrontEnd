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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupView()
    }
    
    private func setupView() {
        self.avatarView.roundFull()
        self.avatarImageView.roundFull()
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
    
}
