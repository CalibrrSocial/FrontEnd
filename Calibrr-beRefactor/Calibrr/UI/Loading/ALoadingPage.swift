//
//  ALoadingPage.swift
//  Calibrr
//
//  Created by Kamil Chmurzynski on 10/06/2019.
//  Copyright © 2019 Calibrr. All rights reserved.
//

import UIKit

class ALoadingPage : UIViewController, IPage
{
    @IBOutlet var spinner: CBRActivityIndicatorView!
    
    override var modalPresentationStyle: UIModalPresentationStyle
        {
        get { return .overCurrentContext}
        set {}
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        spinner.startAnimating()
    }
    
    func getBackPage() -> IPage? { return nil }
    func backAction(_ sender: UIButton?) {}
    func reloadData() {}
}
