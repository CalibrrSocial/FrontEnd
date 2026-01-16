//
//  LoadingTransparentPage.swift
//  Calibrr
//
//
//  Copyright © Calibrr. All rights reserved.
//

import UIKit

class LoadingTransparentPage : ALoadingPage
{
    @IBOutlet var background: UIView!
    
    func startAnimation() {
        self.spinner.startAnimating()
    }
}
