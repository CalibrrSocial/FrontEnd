//
//  AutoLoginPage.swift
//  Calibrr
//
//  Created by Kamil Chmurzynski on 18/06/2019.
//  Copyright © 2019 Calibrr. All rights reserved.
//

import UIKit
import PromiseKit
import OpenAPIClient

class AutoLoginPage : APage
{
    lazy var activeUser = ActiveUser.singleton
    lazy var userData = UserData.singleton
    
    @IBOutlet var background: UIView!
    @IBOutlet var logo: UIImageView!
    @IBOutlet var spinner : CBRActivityIndicatorView!
    
    override func showsNavigationBar() -> Bool { return false }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        spinner.startAnimating()
        
        if activeUser.loggedIn {
            nav.show(SearchUsersByDistancePage(), animated: false)
        }else{
            login()
        }
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        Tracking.Track("autologinOpen")
    }
    
    private func login()
    {
        guard let (username, password, method) = userData.getCredentials() else {
            nav.show(LandingPage(), animated: false)
            return
        }
        
        AuthenticationAPI.loginUser(loginAuth: LoginAuth(email: username, phone: nil, password: password)).then{ result in
            self.getUserProfile(result)
        }.then { result -> Promise<Void>  in
            let (result, profile) = (result.0, result.1)
            return self.activeUser.login(self.nav, username, password, method, result.token, Date(), false, profile)
        }
        .catch { e in
            self.activeUser.showLoginError(self.nav, e) {
                self.nav.show(LoginPage(), animated: false, ignoreSameType: true)
            }
        }
    }
    
    private func getUserProfile(_ result: LoginUser) -> Promise<(LoginUser, User)>
    {
        //TODO: fix at some point
        
        OpenAPIClientAPI.customHeaders[APIKeys.HTTP_AUTHORIZATION_HEADER] = APIKeys.HTTP_AUTHORIZATION_PREFIX + result.token
        var user: LoginUser
        user = result
        return ProfileAPI.getUser(id: user.user.id).recover { error -> Promise<User> in
            // If user doesn't exist in AWS DynamoDB yet (404), use the basic profile from login
            if case let ErrorResponse.error(statusCode, _, _, _) = error, statusCode == 404 {
                return Promise.value(result.user)
            }
            throw error
        }.map { profile in
            return (result, profile)
        }
    }
}
