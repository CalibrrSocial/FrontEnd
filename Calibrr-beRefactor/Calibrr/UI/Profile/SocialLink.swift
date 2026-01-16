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
        case twitter = "ic_twitter"
        case vsco = "ic_vsco"
        case tiktok = "ic_tikTok"
        
        var value: String {
            switch self {
            case .instagarm: return "instagram"
            case .facebook: return "facebook"
            case .snapchat: return "snapchat"
            case .twitter: return "twitter"
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
    var numberItem: Int = 6
    
    var sizeScreen: CGFloat = UIScreen.main.bounds.width - 40
    let spacing: CGFloat = 15
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
        stackView.spacing = self.spacing
        self.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
        }
    }
    
    public func reloadData() {
        stackView.arrangedSubviews.forEach( { $0.removeFromSuperview() })
        let sizeItem = (sizeScreen - CGFloat(CGFloat(numberItem - 1) * spacing)) / CGFloat(numberItem)
        
        let numberOfItem = isEditMode ? numberItem : items.count
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
            containerView.addSubview(imageView)
            imageView.snp.makeConstraints { make in
                make.width.height.equalTo(sizeItem)
                make.leading.trailing.top.bottom.equalToSuperview()
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
            socialItem.append(SocialItemData(.twitter, account: twitter))
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
