//
//  SocialLinkTableViewCell.swift
//  Calibrr
//
//
//  Copyright © Calibrr. All rights reserved.
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
        guard let item = item else { return }
        
        // Ensure we're on the main thread for UI operations
        DispatchQueue.main.async {
            let app = UIApplication.shared
            
            var userName = item.account
            if let url = URL(string: userName),
               let name = url.pathComponents.last {
                userName = name
            }
            userName = userName.replacingOccurrences(of: "@", with: "")
            
            // Add a small delay to ensure UI has fully processed the tap before opening external app
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                var success = false
                
                switch item.type {
                case .instagarm:
                    success = app.open(Applications.Instagram(), action: .username(userName))
                case .facebook:
                    success = app.open(Applications.FacebookCustom(), action: .userName(userName))
                case .vsco:
                    success = app.open(Applications.VSCOCustom(), action: .userName(userName))
                case .x:
                    success = app.open(Applications.TwitterCustom(), action: .userName(userName))
                case .linkedin:
                    success = app.open(Applications.LinkedinCustom(), action: .userName(userName))
                case .snapchat:
                    success = app.open(Applications.SnapChatCustom(), action: .userName(userName))
                case .tiktok:
                    success = app.open(Applications.TikTok(), action: .userName(userName))
                }
                
                // Log if opening failed
                if !success {
                    print("Failed to open \(item.type) for username: \(userName)")
                }
            }
        }
    }
}
