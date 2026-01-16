//
//  CBRActivityIndicatorView.swift
//  Calibrr
//
//  Created by Kamil Chmurzynski on 03/06/2019.
//  Copyright © 2019 NCRTS. All rights reserved.
//

import UIKit

class CBRActivityIndicatorView : UIActivityIndicatorView
{
    let indicatorLayer = CAShapeLayer()
    
    init(frame: CGRect = CGRect(x: 0, y: 0, width: 20, height: 20), indicatorColour: UIColor? = nil)
    {
        super.init(frame: frame)
        
        commonSetup(indicatorColour: indicatorColour)
    }
    
    required init(coder: NSCoder)
    {
        super.init(coder: coder)
        
        commonSetup(indicatorColour: nil)
    }
    
    override func tintColorDidChange()
    {
        super.tintColorDidChange()
        
        indicatorLayer.strokeColor = tintColor.cgColor
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        var bounds = self.bounds
        bounds.size.width = min(bounds.size.width, bounds.size.height)
        bounds.size.height = bounds.size.width
        
        indicatorLayer.path = UIBezierPath(ovalIn: bounds).cgPath
    }
    
    override func startAnimating()
    {
        super.startAnimating()
        
        let currentRotation = layer.value(forKey: "transform.rotation.z") as? CGFloat ?? 0
        
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.fromValue = currentRotation
        animation.toValue = currentRotation + CGFloat.pi*2
        animation.duration = 1
        animation.repeatCount = HUGE
        
        layer.add(animation, forKey: "rotation")
    }
    
    private func commonSetup(indicatorColour: UIColor?)
    {
        backgroundColor = UIColor.clear
        color = UIColor.clear
        indicatorLayer.backgroundColor = UIColor.clear.cgColor
        indicatorLayer.fillColor = UIColor.clear.cgColor
        indicatorLayer.strokeColor = (indicatorColour ?? tintColor).cgColor
        indicatorLayer.strokeStart = 0
        indicatorLayer.strokeEnd = 0.75
        indicatorLayer.lineCap = CAShapeLayerLineCap.round
        indicatorLayer.lineWidth = 2.0
        
        layer.addSublayer(indicatorLayer)
    }
}
