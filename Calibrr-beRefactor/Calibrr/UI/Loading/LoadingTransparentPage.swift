//
//  LoadingTransparentPage.swift
//  Calibrr
//
//  Created by Kamil Chmurzynski on 10/06/2019.
//  Copyright © 2019 Calibrr. All rights reserved.
//

import UIKit

class LoadingTransparentPage : ALoadingPage
{
    @IBOutlet var background: UIView!
    
    func startAnimation() {
        self.spinner.startAnimating()
    }
}
