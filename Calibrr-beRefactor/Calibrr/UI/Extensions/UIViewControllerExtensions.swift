//
//  UIViewControllerExtensions.swift
//  Calibrr
//
//  Created by Kamil Chmurzynski on 11/06/2019.
//  Copyright © 2019 Calibrr. All rights reserved.
//

import UIKit

extension UIViewController
{
    func isVisible() -> Bool
    {
        return viewIfLoaded?.window != nil
    }
    
    func animateHeartbeat(view: UIView, widthConstraint: NSLayoutConstraint, heightConstraint: NSLayoutConstraint, sizeBefore: CGFloat)
    {
        setSize(widthConstraint, heightConstraint, sizeBefore * 1.4)
        self.view.layoutIfNeeded()
        
        setSize(widthConstraint, heightConstraint, sizeBefore)
        
        UIView.animate(withDuration: 0.6, animations: {
            self.view.layoutIfNeeded()
            view.alpha = 1
        }, completion: nil)
    }
    
    func hideKeyboardWhenTappedAround()
    {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard()
    {
        view.endEditing(true)
    }
    
    private func setSize(_ widthConstraint: NSLayoutConstraint, _ heightConstraint: NSLayoutConstraint, _ size: CGFloat)
    {
        widthConstraint.constant = size
        heightConstraint.constant = size
    }
}
