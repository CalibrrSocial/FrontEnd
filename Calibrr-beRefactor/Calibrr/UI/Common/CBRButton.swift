//
//  CBRButton.swift
//  Calibrr
//
//  Created by Kamil Chmurzynski on 11/06/2019.
//  Copyright © 2019 Calibrr. All rights reserved.
//

import UIKit
import MaterialComponents
import MaterialComponents.MaterialButtons
import MaterialComponents.MDCButton

class CBRButton : MDCButton
{
    enum CBRButtonType : Int
    {
        case None = -1
        case White = 0
        case ClearWhite = 1
        case Green = 2
        case Red = 3
        case black = 4
    }
    
    @IBInspectable var cbrButtonType : Int = -1
    @IBInspectable var shadowElevation : CGFloat = 4
    var cornerRadius : CGFloat? = nil
    private let activityIndicator = CBRActivityIndicatorView()
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    required init()
    {
        super.init(frame: .zero)
        
        commonInit()
    }
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        commonInit()
    }
    
    func commonInit()
    {
        setupCorners()
        
        isUppercaseTitle = false
        setTitleFont(UIFont.boldSystemFont(ofSize: 14), for: .normal)
        
        setupButtonType()
        
        disabledAlpha = 0.6
    }
    
    open func setupCorners()
    {
        if cornerRadius == nil {
            cornerRadius = bounds.height == 0 ? 30 : bounds.height / 2
        }
        roundCorners(cornerRadius!)
    }
    
    func showWaiting()
    {
        activityIndicator.startAnimating()
        addSubview(activityIndicator)
        
        activityIndicator.snp.makeConstraints({ (make) in
            make.center.equalToSuperview()
            make.height.width.equalTo(30)
        })
        
        isEnabled = false
    }
    
    func showNormal()
    {
        activityIndicator.removeFromSuperview()
        isEnabled = true
    }
    
    func setupWhite(enabled: Bool = true)
    {
        setElevation(ShadowElevation(shadowElevation), for: .normal)
        setBackgroundColor(UIColor.white)
        inkColor = UIColor.cbrGrayLight
        setTitleColor(enabled ? UIColor.black : UIColor.cbrGray, for: .normal)
        setTitleColor(enabled ? UIColor.black : UIColor.cbrGray, for: .disabled)
    }
    
    func setupClearWhite()
    {
        setElevation(ShadowElevation(0), for: .normal)
        setBackgroundColor(UIColor.clear)
        setBorderColor(UIColor.white, for: .normal)
        setBorderWidth(1, for: .normal)
        inkColor = UIColor.cbrGrayLight
        tintColor = UIColor.white
        setTitleColor(UIColor.white, for: .normal)
        setTitleColor(UIColor.white, for: .disabled)
    }
    
    func setupGreen()
    {
        setElevation(ShadowElevation(shadowElevation), for: .normal)
        setBackgroundColor(UIColor.cbrGreen)
        inkColor = UIColor.cbrGrayLight
        tintColor = UIColor.white
        setTitleColor(UIColor.white, for: .normal)
        setTitleColor(UIColor.white, for: .disabled)
    }
    
    func setupRed()
    {
        setElevation(ShadowElevation(shadowElevation), for: .normal)
        setBackgroundColor(UIColor.cbrRed)
        inkColor = UIColor.cbrGrayLight
        tintColor = UIColor.white
        setTitleColor(UIColor.white, for: .normal)
        setTitleColor(UIColor.white, for: .disabled)
    }
    
    func setupBlack()
    {
        setElevation(ShadowElevation(shadowElevation), for: .normal)
        setBackgroundColor(UIColor.black)
        inkColor = UIColor.cbrGrayLight
        tintColor = UIColor.white
        setTitleColor(UIColor.white, for: .normal)
        setTitleColor(UIColor.white, for: .disabled)
    }
    
    private func setupButtonType()
    {
        if cbrButtonType >= 0, let type = CBRButtonType(rawValue: cbrButtonType) {
            switch type {
            case .ClearWhite:
                setupClearWhite()
            case .Green:
                setupGreen()
            case .Red:
                setupRed()
            case .black:
                setupBlack()
            default:
                setupWhite()
            }
        }
    }
}
