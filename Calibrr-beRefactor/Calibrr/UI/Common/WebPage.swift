//
//  WebPage.swift
//  Calibrr
//
//  Created by Kamil Chmurzynski on 12/06/2019.
//  Copyright © 2019 Calibrr. All rights reserved.
//

import UIKit
import WebKit

class WebPage : UIViewController, WKNavigationDelegate
{
    @IBOutlet var backgroundButton : UIButton!
    @IBOutlet var webView : WKWebView!
    
    var url = ""
    
    private var activityIndicator = CBRActivityIndicatorView()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        backgroundButton.isUserInteractionEnabled = false
        
        webView.navigationDelegate = self
        webView.isUserInteractionEnabled = false
        webView.load(URLRequest(url: URL(string: url)!))
        
        
        webView.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        activityIndicator.startAnimating()
    }
    
    @IBAction func close(sender: UIButton)
    {
        dismiss(animated: true)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!)
    {
        backgroundButton.isUserInteractionEnabled = true
        webView.isUserInteractionEnabled = true
        
        activityIndicator.stopAnimating()
        activityIndicator.removeFromSuperview()
    }
}
