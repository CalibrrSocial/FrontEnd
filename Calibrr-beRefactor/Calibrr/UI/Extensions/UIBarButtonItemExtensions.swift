//
//  UIBarButtonItemExtensions.swift
//  Calibrr
//
//  Created by Kamil Chmurzynski on 11/06/2019.
//  Copyright © 2019 Calibrr. All rights reserved.
//

import UIKit

extension UIBarButtonItem
{
    static func CreateBack(target: Any, action: Selector, black: Bool = false) -> UIBarButtonItem
    {
        
        let image = UIImage(named: "icon_back")!.withRenderingMode(.alwaysTemplate).withTintColor(black ? .darkGray : .white)
        
        return UIBarButtonItem(image: image, style: .plain, target: target, action: action).makeAccessible("backButton")
    }
    
    @discardableResult
    func makeAccessible(_ id: String) -> Self
    {
        accessibilityActivate()
        isAccessibilityElement = true
        accessibilityIdentifier = id
        return self
    }
}
