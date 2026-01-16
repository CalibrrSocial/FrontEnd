//
//  APage.swift
//  Calibrr
//
//
//  Copyright © Calibrr. All rights reserved.
//

import UIKit

class APage : UIViewController, IPage
{
    var nav : CBRNavigator { get{ return navigationController as? CBRNavigator ?? AppDelegate.shared.window?.rootViewController as! CBRNavigator} }
    
    private var rightBarButton : UIBarButtonItem? = nil
    private let backgroundTapRecognizer = UITapGestureRecognizer()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        backgroundTapRecognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(backgroundTapRecognizer)
        backgroundTapRecognizer.addTarget(self, action: #selector(backgroundTapped(sender:)))
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        setNeedsStatusBarAppearanceUpdate()
        
        setupNavBar()
        
        reloadData()
    }
    
    
    func getStatusBarHeight() -> CGFloat {
       var statusBarHeight: CGFloat = 0
       if #available(iOS 13.0, *) {
           let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
           statusBarHeight = window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
       } else {
           statusBarHeight = UIApplication.shared.statusBarFrame.height
       }
       return statusBarHeight
   }

    override var preferredStatusBarStyle: UIStatusBarStyle { get { return UIStatusBarStyle.lightContent } }
    
    @objc func backgroundTapped(sender: UIButton)
    {
        view.endEditing(true)
    }
    
    func showsNavigationBar() -> Bool
    {
        return true
    }
    
    func forceMenuButton() -> Bool
    {
        return false
    }
    
    func setupMenuButton(_ notifications: Int = 0, tintColor: UIColor = .white)
    {
        navigationItem.leftBarButtonItem = CBRBadgeBarButtonItem.CreateMenu(target: self, action: #selector(menuAction(sender:)), badgeCount: notifications, tintColor: tintColor)
        navigationItem.leftBarButtonItem?.tintColor = tintColor
    }
    
    
    func updateMenuButton(notifications: Int)
    {
        if let menuButton = navigationItem.leftBarButtonItem as? CBRBadgeBarButtonItem {
            menuButton.update(badgeCount: notifications)
        }
    }
    
    @objc func menuAction(sender: UIBarButtonItem?)
    {
        nav.showMenu()
    }
    
    func setupBackButton(tintColor: UIColor = .white)
    {
        navigationItem.leftBarButtonItem = UIBarButtonItem.CreateBack(target: self, action: #selector(backAction(_:)))
        navigationItem.leftBarButtonItem?.tintColor = tintColor
    }
    
    func getBackPage() -> IPage?
    {
        return nil
    }
    
    @objc func backAction(_ sender: UIButton? = nil)
    {
        nav.pop(animated: true)
    }
    
    func reloadData()
    {
        refreshUI()
    }
    
    func refreshUI() {}
    
    //UI Helpers
    
    func showMenuProgressIndicator()
    {
        rightBarButton = navigationItem.rightBarButtonItem
        navigationItem.rightBarButtonItem = CBRProgressBarButtonItem()
    }
    
    func isShowingMenuProgressIndicator() -> Bool
    {
        return navigationItem.rightBarButtonItem as? CBRProgressBarButtonItem != nil
    }
    
    func hideMenuProgressIndicator()
    {
        navigationItem.rightBarButtonItem = rightBarButton
        rightBarButton = nil
    }
    
    private func setupNavBar()
    {
        navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        
        nav.setNavigationBarHidden(!showsNavigationBar(), animated: true)
        
        if showsNavigationBar() {
            nav.setupDefault()
            
            if forceMenuButton() || nav.getPagesCount() <= 1 {
                setupMenuButton()
            }else{
                setupBackButton()
            }
        }
    }
}
