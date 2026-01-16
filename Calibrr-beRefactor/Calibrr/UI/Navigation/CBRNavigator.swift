//
//  CBRNavigator.swift
//  Calibrr
//
//  Created by Kamil Chmurzynski on 10/06/2019.
//  Copyright © 2019 Calibrr. All rights reserved.
//

import UIKit
import SnapKit

class CBRNavigator : UINavigationController
{
    let userData = UserData.singleton
    
    let menuPage = MenuPage()
    let fullScreenLoadingPage = LoadingPage()
    let transparentLoadingPage = LoadingTransparentPage()
    
    override func loadView()
    {
        super.loadView()
        
        prepareViews()
        
        if showAutoLogin() {
            show(AutoLoginPage(), animated: false)
        }else {
            show(LandingPage(), animated: false)
        }
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        setNavigationBarHidden(false, animated: true)
    }
    
    override var childForStatusBarStyle: UIViewController? { get { return topViewController } }
    
    func getPagesCount() -> Int { return viewControllers.count }
    
    func showMenu()
    {
        menuPage.show()
    }
    
    func show(_ page: IPage, animated: Bool = false, ignoreSameType: Bool = false)
    {
        if ignoreSameType {
            if type(of: topViewController) == type(of: page) {
                return
            }
        }
        
        var vcs = [UIViewController]()
        var currentPage = page
        while let backPage = currentPage.getBackPage() {
            vcs.append(backPage as! UIViewController)
            currentPage = backPage
        }
        if vcs.count > 0 {
            viewControllers = vcs.reversed()
            push(page, animated: animated)
        }else{
            pushAsFirst(page, animated: animated)
        }
    }
    
    func push(_ page: IPage, animated: Bool = true, completion: (() -> Void)? = nil)
    {
        if !isTop(page) {
            pushViewController(page as! UIViewController, animated: true)
            if let completion = completion {
                animated ? doAfterAnimatingTransition(completion: completion) : completion()
            }
        }
    }
    
    func pushAsFirst(_ page: IPage, animated: Bool = true)
    {
        let isTopPage = isTop(page)
        if !animated || isTopPage {
            viewControllers = [page as! UIViewController]
            if isTopPage {
                page.reloadData()
            }
            return
        }
        push(page, animated: animated, completion: {
            self.viewControllers = [page as! UIViewController]
        })
    }
    
    func pushAsFirst(_ page: IPage, rootPage: IPage, animated: Bool = true)
    {
        push(page, animated: animated, completion: {
            self.viewControllers = [rootPage as! UIViewController, page as! UIViewController]
        })
    }
    
    func pop(animated: Bool = true, completion: (() -> Void)? = nil)
    {
        popViewController(animated: animated)
        
        if let completion = completion {
            animated ? doAfterAnimatingTransition(completion: completion) : completion()
        }
    }
    
    func isShowingTransparentLoading() -> Bool
    {
        return transparentLoadingPage.isVisible()
    }
    
    func showTransparentLoading()
    {
        if !isShowingTransparentLoading() {
            view.addSubview(transparentLoadingPage.view)
        }
    }
    
    func hideTransparentLoading()
    {
        if isShowingTransparentLoading() {
            transparentLoadingPage.view.removeFromSuperview()
        }
    }
    
    func showFullScreenLoading()
    {
        if !fullScreenLoadingPage.isVisible() {
            view.addSubview(fullScreenLoadingPage.view)
        }
    }
    
    func hideFullScrenLoading()
    {
        if fullScreenLoadingPage.isVisible() {
            fullScreenLoadingPage.view.removeFromSuperview()
        }
    }
    
    //UI Functions
    
    func setupDefault()
    {
        view.backgroundColor = UIColor.clear
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.titleTextAttributes = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 18, weight: .medium),
                                             NSAttributedString.Key.foregroundColor : UIColor.white]
        navigationBar.backgroundColor = UIColor.clear
        navigationBar.isTranslucent = true
    }
    
    func updateColor(color: UIColor, isShowShadow: Bool) {
        navigationBar.backgroundColor = color
        view.backgroundColor = color
        navigationBar.barTintColor = color
        let view = self.navigationBar.subviews.first { view in
            return String(describing: type(of: view.self)) == "_UIBarBackground"
        }
        
        view?.backgroundColor = color
        
        if view?.subviews.filter({ view in
            return view.tag == 883
        }).isEmpty ?? true {
            let shadowView = UIView()
            shadowView.tag = 883
            view?.addSubview(shadowView)
            
            shadowView.snp.makeConstraints { make in
                // print("🔍 CBRNavigator: About to set shadowView constraints. ShadowView.superview: \(shadowView.superview != nil ? "EXISTS" : "NIL")")
                if shadowView.superview != nil {
                    make.bottom.left.right.equalToSuperview()
                } else {
                    // print("🔍 CBRNavigator: Skipping shadowView equalToSuperview constraints - shadowView has no superview")
                    if let parentView = view {
                        make.bottom.left.right.equalTo(parentView)
                    } else {
                        // print("🔍 CBRNavigator: ERROR - Both shadowView.superview and parentView are nil, cannot set constraints")
                        return
                    }
                }
                make.height.equalTo(1)
            }
        }
        
        let shadowView = view?.subviews.first { view in
            return view.tag == 883
        }
        
        shadowView?.backgroundColor = isShowShadow ? .lightGray : .clear
        
        navigationBar.titleTextAttributes = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 18.0, weight: .medium),
                                             NSAttributedString.Key.foregroundColor : color == .clear ? UIColor.white : UIColor.darkGray]
    }
    
    func setupFilled()
    {
        view.backgroundColor = UIColor.white
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.titleTextAttributes = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 18.0, weight: .medium),
                                             NSAttributedString.Key.foregroundColor : UIColor.black]
        navigationBar.backgroundColor = UIColor.clear
        navigationBar.isTranslucent = false
    }
    
    //INTERNAL
    
    private func showAutoLogin() -> Bool
    {
        return userData.wasLoggedIn() && userData.hasCredentials()
    }
    
    private func prepareViews()
    {
        let _ = menuPage.view
        menuPage.setup(self)
        
        let _ = fullScreenLoadingPage.view
        fullScreenLoadingPage.view.frame = view.frame
        
        let _ = transparentLoadingPage.view
        transparentLoadingPage.view.frame = view.frame
    }
    
    private func doAfterAnimatingTransition(completion: @escaping (() -> Void))
    {
        if let coordinator = transitionCoordinator {
            coordinator.animate(alongsideTransition: nil, completion: { _ in
                DispatchQueue.main.async {
                    completion()
                }
            })
        } else {
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
    private func isTop(_ page: IPage) -> Bool
    {
        return topViewController == (page as? UIViewController)
    }
}
