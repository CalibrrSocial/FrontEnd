//
//  AFilledPage.swift
//  Calibrr
//
//
//  Copyright © Calibrr. All rights reserved.
//

import UIKit

class AFilledPage : APage
{
    override public func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        nav.setupFilled()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle { get { return UIStatusBarStyle.default } }
    
    override func setupBackButton(tintColor: UIColor = .white) {
        navigationItem.leftBarButtonItem = UIBarButtonItem.CreateBack(target: self, action: #selector(backAction(_:)), black: true)
        navigationItem.leftBarButtonItem?.tintColor = .darkGray
    }
}
