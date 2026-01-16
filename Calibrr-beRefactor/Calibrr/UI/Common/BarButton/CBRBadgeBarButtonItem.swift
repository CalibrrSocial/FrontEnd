//
//  CBRBadgeBarButtonItem.swift
//  Calibrr
//
//
//  Copyright © Calibrr. All rights reserved.
//

import UIKit

class CBRBadgeBarButtonItem : UIBarButtonItem
{
    private let badgeIcon = UIImageView()
    private let badgeBubble = CBRBadgeView()
    
    override init()
    {
        super.init()
        
        width = 60
        
        customView = UIView()
        customView!.snp.makeConstraints { (make) in
            make.height.equalTo(44)
        }
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    func setup()
    {
        customView!.backgroundColor = .clear
        
        badgeIcon.contentMode = .scaleAspectFill
        customView!.addSubview(badgeIcon)
        badgeIcon.snp.makeConstraints { (make) in
            make.width.height.equalTo(24)
            make.centerX.centerY.equalToSuperview()
        }
        
        customView!.addSubview(badgeBubble)
        badgeBubble.snp.makeConstraints { (make) in
            make.width.height.equalTo(24)
            make.centerX.equalTo(badgeIcon.snp.right)
            make.centerY.equalTo(badgeIcon.snp.top)
        }
    }
    
    func setup(target: Any, action: Selector, image: UIImage, badgeCount: Int, red: Bool = true) -> CBRBadgeBarButtonItem
    {
        let gestureRecognizer = UITapGestureRecognizer(target: target, action: action)
        customView!.addGestureRecognizer(gestureRecognizer)
        
        badgeIcon.image = image.withRenderingMode(.alwaysOriginal)
        badgeBubble.setup(badgeCount: badgeCount, red: red)
        
        makeAccessible("badgeBarButtonItem")
        return self
    }
    
    func update(badgeCount: Int)
    {
        badgeBubble.update(badgeCount: badgeCount)
    }
    
    func showError(show: Bool = true)
    {
        badgeBubble.showError(show: show)
    }
    
    static func CreateMenu(target: Any, action: Selector, badgeCount: Int, tintColor: UIColor) -> CBRBadgeBarButtonItem
    {
        let item = CBRBadgeBarButtonItem().setup(target: target, action: action, image: UIImage(named: "icon_menu")!.withRenderingMode(.alwaysTemplate).withTintColor(tintColor), badgeCount: badgeCount).makeAccessible("menuButton")
        return item
    }
}
