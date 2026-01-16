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
        print("🔍 SocialLinkTableViewCell: awakeFromNib called")
        // Initialization code
        socialView.delegate = self
        print("🔍 SocialLinkTableViewCell: awakeFromNib completed")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupData(account: UserSocialInfo?) {
        print("🔍 SocialLinkTableViewCell: setupData called with account: \(account != nil ? "EXISTS" : "NIL")")
        self.socialView.setupData(account: account)
        print("🔍 SocialLinkTableViewCell: setupData completed")
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
        case .x:
            app.open(Applications.TwitterCustom(), action: .userName(userName))
        case .linkedin:
            app.open(Applications.LinkedinCustom(), action: .userName(userName))
        case .snapchat:
            app.open(Applications.SnapChatCustom(), action: .userName(userName))
        case .tiktok:
            app.open(Applications.TikTok(), action: .userName(userName))
        }
    }
}
