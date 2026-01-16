//
//  SocialLink.swift
//  Calibrr
//
//  Created by ZVN20210023 on 03/02/2023.
//  Copyright © 2023 Calibrr. All rights reserved.
//

import UIKit
import SnapKit
import OpenAPIClient

protocol SocialLinkDelegate {
    func didTapOnItem(item: SocialItemData?)
}

class MyTapGesture: UITapGestureRecognizer {
    var tag: Int = 0
}

public class SocialItemData {
    enum SocialItem: String {
        case instagarm = "ic_instagram"
        case facebook = "ic_facebook"
        case snapchat = "ic_snapchat"
        case linkedin = "ic_linkedin"
        case x = "ic_x"
        case vsco = "ic_vsco"
        case tiktok = "ic_tikTok"
        
        var value: String {
            switch self {
            case .instagarm: return "instagram"
            case .facebook: return "facebook"
            case .snapchat: return "snapchat"
            case .linkedin: return "linkedin"
            case .x: return "x"
            case .vsco: return "vsco"
            case .tiktok: return "tiktok"
            }
        }
    }
    
    var account: String = ""
    var type: SocialItem
    init(_ type: SocialItem,
         account: String = "") {
        self.type = type
        self.account = account
    }
}

class SocialLink: UIView {
    
    var stackView = UIStackView()
    var isEditMode: Bool = false
    var items: [SocialItemData] = []
    var activeItem: SocialItemData? {
        didSet {
            if activeItem == nil {
                stackView.arrangedSubviews.forEach( { $0.alpha = 1.0 })
            } else {
                if let index = items.firstIndex(where: { $0.type == activeItem?.type }) {
                    for view in stackView.arrangedSubviews {
                        view.alpha = view.tag == index ? 1 : 0.3
                    }
                }
            }
            
        }
    }
    var numberItem: Int = 7
    
    var sizeScreen: CGFloat = UIScreen.main.bounds.width - 24 - 16  // Account for cell margins (24pt) + stack view margins (16pt)
    let spacing: CGFloat = 8
    var delegate: SocialLinkDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        stackView.axis = .horizontal
        stackView.spacing = 16.0  // Use consistent spacing
        stackView.distribution = .equalCentering  // Center icons with equal spacing
        stackView.alignment = .center
        
        self.addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(8)  // Add 8pt margins to prevent cutoff
            make.top.bottom.equalToSuperview()
            make.centerX.centerY.equalToSuperview()  // Center both horizontally and vertically
        }
    }
    
    public func reloadData() {
        stackView.arrangedSubviews.forEach( { $0.removeFromSuperview() })
        
        // Calculate available social media platforms dynamically
        let availablePlatforms = 7  // instagram, facebook, snapchat, linkedin, x, vsco, tiktok
        let numberOfItem = isEditMode ? availablePlatforms : items.count
        
        let optimalSpacing: CGFloat = 16.0  // Increased spacing for better visual separation
        
        // Update stack view spacing
        stackView.spacing = optimalSpacing
        
        // Calculate icon size with better space utilization
        let optimalIconSize: CGFloat
        
        if isEditMode {
            // In edit mode, size for all 7 platforms for consistency
            let totalSpacingForAllPlatforms = (7.0 - 1) * optimalSpacing
            let availableWidthForIcons = sizeScreen - totalSpacingForAllPlatforms
            optimalIconSize = availableWidthForIcons / 7.0
        } else {
            // In view mode, use actual number of items for better space utilization
            // but ensure minimum reasonable size
            let actualItemsForSpacing = CGFloat(numberOfItem)
            let totalSpacingForActualItems = max(0, (actualItemsForSpacing - 1)) * optimalSpacing
            let availableWidthForIcons = sizeScreen - totalSpacingForActualItems
            optimalIconSize = numberOfItem > 0 ? availableWidthForIcons / actualItemsForSpacing : 60.0
        }
        
        // Set minimum and maximum sizes for better usability and appearance
        // Ensure icons don't exceed available space to prevent cutoff and overlap
        let maxSafeSize = min(75.0, (sizeScreen - (CGFloat(numberOfItem - 1) * optimalSpacing)) / CGFloat(numberOfItem))
        let finalSizeItem = min(max(optimalIconSize, 50.0), maxSafeSize)  // Between 50pt and safe maximum
        
        print("🔍 SocialLink Debug - Items: \(numberOfItem), ScreenWidth: \(sizeScreen), OptimalSize: \(optimalIconSize), MaxSafe: \(maxSafeSize), Final: \(finalSizeItem)")
        
        for i in 0..<numberOfItem {
            let containerView = UIView()
            containerView.tag = i
            let imageView = UIImageView()
            let button = UIButton()
            button.tag = i
            button.addTarget(self, action: #selector(self.didTapIcon(_:)), for: .touchUpInside)
            
            if let imageURL = items[safe: i] {
                imageView.image = UIImage(named: imageURL.type.rawValue)
            } else {
                imageView.image = UIImage(named: "ic_addSocial")
            }
            
            // Set image content mode and make circular with border
            imageView.contentMode = .scaleAspectFit
            imageView.layer.cornerRadius = finalSizeItem / 2
            imageView.clipsToBounds = true
            imageView.backgroundColor = UIColor.clear
            
            // Add subtle border for better visibility
            imageView.layer.borderWidth = 0.5
            imageView.layer.borderColor = UIColor.systemGray4.cgColor
            
            // Add subtle shadow to container (since imageView clips bounds)
            containerView.layer.shadowColor = UIColor.black.cgColor
            containerView.layer.shadowOffset = CGSize(width: 0, height: 1)
            containerView.layer.shadowRadius = 2
            containerView.layer.shadowOpacity = 0.1
            containerView.layer.cornerRadius = finalSizeItem / 2
            
            containerView.addSubview(imageView)
            
            imageView.snp.makeConstraints { make in
                make.width.height.equalTo(finalSizeItem)
                make.center.equalToSuperview()
            }
            
            containerView.addSubview(button)
            
            button.snp.makeConstraints { make in
                make.leading.trailing.bottom.top.equalToSuperview()
            }
            
            stackView.addArrangedSubview(containerView)
        }
    }
    
    @objc func didTapIcon(_ sender: UIButton) {
        self.delegate?.didTapOnItem(item: items[safe: sender.tag])
    }
    
    public func getValidAccount() -> [SocialItemData] {
        return self.items.filter({ !$0.account.isEmpty })
    }
    
    public func setupData(account: UserSocialInfo?) {
        guard let account = account else { return }
        var socialItem: [SocialItemData] = []
        if let instagram = account.instagram,
           !instagram.isEmpty {
            socialItem.append(SocialItemData(.instagarm, account: instagram))
        }
        
        if let vsco = account.vsco,
           !vsco.isEmpty {
            socialItem.append(SocialItemData(.vsco, account: vsco))
        }
        
        if let snapchat = account.snapchat,
           !snapchat.isEmpty {
            socialItem.append(SocialItemData(.snapchat, account: snapchat))
        }
        
        if let twitter = account.twitter,
           !twitter.isEmpty {
            socialItem.append(SocialItemData(.x, account: twitter))
        }
        
        if let linkedin = account.linkedIn,
           !linkedin.isEmpty {
            socialItem.append(SocialItemData(.linkedin, account: linkedin))
        }
        
        if let tiktok = account.tiktok,
           !tiktok.isEmpty {
            socialItem.append(SocialItemData(.tiktok, account: tiktok))
        }
        
        if let facebook = account.facebook,
           !facebook.isEmpty {
            socialItem.append(SocialItemData(.facebook, account: facebook))
        }
        self.items = socialItem
        self.reloadData()
    }
}

extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
