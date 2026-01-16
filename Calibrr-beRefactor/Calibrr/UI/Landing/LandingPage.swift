//
//  LandingPage.swift
//  Calibrr
//
//  Created by Kamil Chmurzynski on 11/06/2019.
//  Copyright © 2019 Calibrr. All rights reserved.
//

import UIKit

class LandingPage : APage
{
    lazy var userData = UserData.singleton
    
    static let ANIMATIONS_DURATION = 1.2
    static let ANIMATIONS_DELAY = 0.1
    
    @IBOutlet var logo : UIImageView!
    @IBOutlet var loginButton : UIButton!
    @IBOutlet var createAccountButton : CBRButton!
    @IBOutlet var logoWidthConstraint : NSLayoutConstraint!
    @IBOutlet var logoHeightConstraint : NSLayoutConstraint!
    @IBOutlet var bottomViewsToAnimate : [UIView]!
    @IBOutlet weak var withoutAccountButton: CBRButton!
    
    private var logoSizeBefore : CGFloat = 0
    private var bottomViewsBefore = [CGFloat]()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        title = "Calibrr"
        
        logoSizeBefore = logoWidthConstraint.constant
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        prepareAnimations()
        
        animateViews()
        logo.alpha = 0
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        Tracking.Track("landingOpen")
        if !userData.wasLoggedIn() {
            Tracking.Track("landingOpenFresh")
        }
        
        animateHeartbeat(view: logo, widthConstraint: logoWidthConstraint, heightConstraint: logoHeightConstraint, sizeBefore: logoSizeBefore)
    }
    
    override func showsNavigationBar() -> Bool { return false }
    
    @IBAction func clickLogin(sender: UIButton)
    {
        Tracking.Track("landingClickLogin")
        
        nav.push(LoginPage())
    }
    
    @IBAction func clickCreateAccount(sender: UIButton)
    {
        Tracking.Track("landingClickCreateAccount")
        
        nav.push(CreateAccountPage())
    }
    
    @IBAction func withoutAccount(_ sender: Any) {
        
    }
    
    private func prepareAnimations()
    {
        for i in 0..<bottomViewsToAnimate.count {
            let v = bottomViewsToAnimate[i]
            bottomViewsBefore.append(v.center.y)
            v.center = CGPoint(x: v.center.x, y: v.center.y + view.frame.height)
        }
    }
    
    private func animateViews()
    {
        for i in 0..<bottomViewsToAnimate.count {
            let v = bottomViewsToAnimate[i]
            
            UIView.animate(withDuration: LandingPage.ANIMATIONS_DURATION + Double(i)*LandingPage.ANIMATIONS_DELAY, animations: {
                v.center = CGPoint(x: v.center.x, y: self.bottomViewsBefore[i])
            })
        }
    }
}
