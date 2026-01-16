//
//  AMenuPage.swift
//  Calibrr
//
//  Created by Kamil Chmurzynski on 10/06/2019.
//  Copyright © 2019 Calibrr. All rights reserved.
//

import UIKit

class AMenuPage : UIViewController
{
    static let MENU_WIDTH_PERCENTAGE : CGFloat = 0.9
    
    @IBOutlet var mainView: UIView!
    @IBOutlet var mainViewLeftConstraint: NSLayoutConstraint!
    @IBOutlet var rightBar: UIView!
    @IBOutlet var rightBarLeftConstraint: NSLayoutConstraint!
    @IBOutlet var topView: UIView!
    
    var nav : CBRNavigator?
    private var mainViewFrame : CGRect?
    private var rightBarFrame : CGRect?
    private let swipeRecognizer = UISwipeGestureRecognizer()
    private let tapRecognizer = UITapGestureRecognizer()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    
        view.addGestureRecognizer(swipeRecognizer)
        swipeRecognizer.direction = .left
        swipeRecognizer.addTarget(self, action: #selector(swiped(sender:)))
        
        rightBar.addGestureRecognizer(tapRecognizer)
        tapRecognizer.addTarget(self, action: #selector(swiped(sender:)))
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        Tracking.Track("menuOpen")
    }
    
    func setup(_ navigator: CBRNavigator)
    {
        nav = navigator
        view.frame = nav!.view.frame
    }
    
    func show()
    {
        nav!.view.addSubview(view)
        
        reloadData()
        
        setViewsOut()
        
        UIView.animate(withDuration: 0.3, animations:
        {
            self.setViewsIn()
        })
    }
    
    @objc func swiped(sender: UIButton)
    {
        animateOut()
    }
    
    func refreshUI(){}
    
    internal func transitionTo(_ page: IPage)
    {
        nav!.show(page)
        
        animateOut()
    }
    
    private func reloadData()
    {
        refreshUI()
    }
    
    private func animateOut()
    {
        view.layoutIfNeeded()
        UIView.animate(withDuration: 0.3, animations:
        {
            self.setViewsOut()
        }, completion: { result in
            self.view.removeFromSuperview()
        })
    }
    
    private func setViewsIn()
    {
        mainViewLeftConstraint.constant = 0
        rightBarLeftConstraint.constant = 0
        rightBar.alpha = 1
        view.layoutIfNeeded()
    }
    
    private func setViewsOut()
    {
        mainViewLeftConstraint.constant = -mainView.frame.width
        rightBarLeftConstraint.constant = mainView.frame.width*2 + rightBar.frame.width
        rightBar.alpha = 0
        view.layoutIfNeeded()
    }
}
