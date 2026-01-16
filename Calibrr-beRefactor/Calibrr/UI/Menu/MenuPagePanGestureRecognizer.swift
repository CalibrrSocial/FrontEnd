//
//  MenuPagePanGestureRecognizer.swift
//  Calibrr
//
//  Created by Kamil Chmurzynski on 10/06/2019.
//  Copyright © 2019 Calibrr. All rights reserved.
//

import UIKit

class MenuPagePanGestureRecognizer : UIPanGestureRecognizer
{
    var dragging = false
    var startPoint = CGPoint.zero
    let kDirectionPanThreshold : CGFloat = 5
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent)
    {
        super.touchesBegan(touches, with: event)
    
        startPoint = touches.first!.location(in: view)
        dragging = false
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent)
    {
        super.touchesMoved(touches, with: event)
        
        if dragging || state == .failed {
            return
        }
        
        let nowPoint = touches.first!.location(in: view)
        
        if abs(nowPoint.x - startPoint.x) > kDirectionPanThreshold {
            dragging = true
        } else if abs(nowPoint.y - startPoint.y) > kDirectionPanThreshold {
            state = .failed
        }
    }
}
