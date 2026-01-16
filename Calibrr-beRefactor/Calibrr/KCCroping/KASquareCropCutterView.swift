//
//  KASquareCropCutterView.swift
//  Calibrr
//
//  Created by _MacBook on 06/05/19.
//  Copyright © 2019 . All rights reserved.
//


import UIKit

class KASquareCropCutterView: UIView {
    
    override var frame: CGRect {
        
        didSet {
            setNeedsDisplay()
        }
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isOpaque = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.isOpaque = false
    }
    
    override func draw(_ rect: CGRect) {
        
        let context = UIGraphicsGetCurrentContext()
        
        UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.7).setFill()
        UIRectFill(rect)
        
      //  This is the same rect as the UIScrollView size 320 * 320, remains centered
        let circle = UIBezierPath(rect: CGRect(x: rect.size.width/2 - 320/2, y: rect.size.height/2 - 180/2, width: 320, height: 180))
      //  let bezierPath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: 40.0, height: 40.0), cornerRadius: 3.0)
        context?.setBlendMode(.clear)
        UIColor.clear.setFill()
        circle.fill()
        
        //This is the same rect as the UIScrollView size 320 * 320, remains centered
         let square = UIBezierPath(rect: CGRect(x: rect.size.width/2 - 320/2, y: rect.size.height/2 - 180/2, width: 320, height: 180))
          UIColor.lightGray.setStroke()
          square.lineWidth = 1.0
        context?.setBlendMode(.normal)
       // UIColor.clear.setFill()
        square.stroke()
        
    }
    
    //Allow touches through the circle crop cutter view
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        for subview in subviews as [UIView] {
            if !subview.isHidden && subview.alpha > 0 && subview.isUserInteractionEnabled && subview.point(inside: convert(point, to: subview), with: event) {
                return true
            }
        }
        return false
    }
    
}
