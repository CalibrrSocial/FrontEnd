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
    
    var sizeScreen: CGFloat = UIScreen.main.bounds.width - 24
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
        print("🔍 SocialLink setupView called")
        stackView.axis = .horizontal
        stackView.spacing = self.spacing
        stackView.distribution = .fillEqually  // Ensure equal distribution
        stackView.alignment = .center
        
        print("🔍 SocialLink: About to add stackView to superview. Self.superview: \(self.superview != nil ? "EXISTS" : "NIL")")
        self.addSubview(stackView)
        
        print("🔍 SocialLink: About to set constraints. StackView.superview: \(stackView.superview != nil ? "EXISTS" : "NIL")")
        stackView.snp.makeConstraints { make in
            print("🔍 SocialLink: Inside constraint block. StackView.superview: \(stackView.superview != nil ? "EXISTS" : "NIL")")
            if stackView.superview != nil {
                make.leading.trailing.top.equalToSuperview()
                make.centerX.equalToSuperview()  // Center the stack view
            } else {
                print("🔍 SocialLink: Skipping equalToSuperview constraints - stackView has no superview")
                // Fallback constraints
                make.leading.trailing.top.equalTo(self)
                make.centerX.equalTo(self)
            }
        }
        print("🔍 SocialLink setupView completed successfully")
    }
    
    public func reloadData() {
        stackView.arrangedSubviews.forEach( { $0.removeFromSuperview() })
        
        // Calculate available social media platforms dynamically
        let availablePlatforms = 7  // instagram, facebook, snapchat, linkedin, x, vsco, tiktok
        let numberOfItem = isEditMode ? availablePlatforms : items.count
        
        // Dynamic spacing based on content type
        let isShowingPlaceholders = items.isEmpty || isEditMode
        let dynamicSpacing: CGFloat = isShowingPlaceholders ? 29 : spacing  // More space for placeholders
        
        // Update stack view spacing dynamically
        stackView.spacing = dynamicSpacing
        
        // Ensure we don't exceed available platforms and calculate size properly
        let actualCount = min(numberOfItem, availablePlatforms)
        let totalSpacing = CGFloat(actualCount - 1) * dynamicSpacing
        let availableWidth = sizeScreen - totalSpacing
        let sizeItem = availableWidth / CGFloat(actualCount)
        
        // Ensure minimum size for readability
        let finalSizeItem = max(sizeItem, 35.0)  // Minimum 35pt size
        
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
            
            // Set image content mode to maintain aspect ratio
            imageView.contentMode = .scaleAspectFit
            
            print("🔍 SocialLink reloadData: About to add imageView \(i) to containerView. ContainerView.superview: \(containerView.superview != nil ? "EXISTS" : "NIL")")
            containerView.addSubview(imageView)
            
            print("🔍 SocialLink reloadData: About to set imageView \(i) constraints. ImageView.superview: \(imageView.superview != nil ? "EXISTS" : "NIL")")
            imageView.snp.makeConstraints { make in
                print("🔍 SocialLink reloadData: Inside imageView \(i) constraint block. ImageView.superview: \(imageView.superview != nil ? "EXISTS" : "NIL")")
                make.width.height.equalTo(finalSizeItem)
                if imageView.superview != nil {
                    make.center.equalToSuperview()
                } else {
                    print("🔍 SocialLink: Skipping imageView equalToSuperview constraint - imageView has no superview")
                    make.center.equalTo(containerView)
                }
            }
            
            print("🔍 SocialLink reloadData: About to add button \(i) to containerView")
            containerView.addSubview(button)
            
            print("🔍 SocialLink reloadData: About to set button \(i) constraints. Button.superview: \(button.superview != nil ? "EXISTS" : "NIL")")
            button.snp.makeConstraints { make in
                print("🔍 SocialLink reloadData: Inside button \(i) constraint block. Button.superview: \(button.superview != nil ? "EXISTS" : "NIL")")
                if button.superview != nil {
                    make.leading.trailing.bottom.top.equalToSuperview()
                } else {
                    print("🔍 SocialLink: Skipping button equalToSuperview constraint - button has no superview")
                    make.leading.trailing.bottom.top.equalTo(containerView)
                }
            }
            
            print("🔍 SocialLink reloadData: About to add containerView \(i) to stackView")
            stackView.addArrangedSubview(containerView)
            print("🔍 SocialLink reloadData: Completed item \(i)")
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
