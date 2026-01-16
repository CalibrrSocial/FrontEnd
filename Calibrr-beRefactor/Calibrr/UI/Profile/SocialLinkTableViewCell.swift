//
//  SocialLinkTableViewCell.swift
//  Calibrr
//
//  Created by ZVN20210023 on 09/02/2023.
//  Copyright © 2023 Calibrr. All rights reserved.
//

import UIKit
import OpenAPIClient

class SocialLinkTableViewCell: UITableViewCell, SocialLinkDelegate {

    @IBOutlet weak var socialView: SocialLink!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        socialView.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupData(account: UserSocialInfo?) {
        self.socialView.setupData(account: account)
    }
    
    func didTapOnItem(item: SocialItemData?) {
        let app = UIApplication.shared
        guard let item = item else { return }
        var userName = item.account
        if let url = URL(string: userName),
           let name = url.pathComponents.last {
            userName = name
        }
        userName = userName.replacingOccurrences(of: "@", with: "")
        switch item.type {
        case .instagarm:
            app.open(Applications.Instagram(), action: .username(userName))
        case .facebook:
            app.open(Applications.FacebookCustom(), action: .userName(userName))
        case .vsco:
            app.open(Applications.VSCOCustom(), action: .userName(userName))
        case .twitter:
            app.open(Applications.TwitterCustom(), action: .userName(userName))
        case .snapchat:
            app.open(Applications.SnapChatCustom(), action: .userName(userName))
        case .tiktok:
            app.open(Applications.TikTok(), action: .userName(userName))
        }
    }
}
