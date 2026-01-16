//
//  CBRBadgeView.swift
//  Calibrr
//
//
//  Copyright © Calibrr. All rights reserved.
//

import UIKit

class CBRBadgeView : UIView
{
    let bubble = UIImageView()
    let bubbleLabel = UILabel()
    
    init()
    {
        super.init(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        
        setup()
    }
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    func setup(badgeCount: Int, red: Bool = true)
    {
        bubble.image = red ? #imageLiteral(resourceName: "circle_red") : #imageLiteral(resourceName: "circle_blue")
        update(badgeCount: badgeCount)
    }
    
    func update(badgeCount: Int)
    {
        let count = max(0, badgeCount)
        
        bubbleLabel.text = count >= 100 ? "99+" : "\(count)"
        isHidden = count == 0
    }
    
    func showError(show: Bool = true)
    {
        bubbleLabel.text = "!"
        isHidden = !show
    }
    
    private func setup()
    {
        makeAccessible("Badge")
        bubbleLabel.makeAccessible("BubbleLabel")
        
        backgroundColor = .clear
        
        bubble.contentMode = .scaleAspectFit
        addSubview(bubble)
        bubble.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalToSuperview()
        }
        
        bubbleLabel.font = UIFont.boldSystemFont(ofSize: 12.0)
        bubbleLabel.textColor = .white
        bubbleLabel.textAlignment = .center
        bubble.addSubview(bubbleLabel)
        bubbleLabel.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalToSuperview()
        }
    }
}
