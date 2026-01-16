//
//  LoginPage.swift
//  Calibrr
//
//  Created by Kamil Chmurzynski on 11/06/2019.
//  Copyright © 2019 Calibrr. All rights reserved.
//

import UIKit
import PromiseKit
import OpenAPIClient

class LoginPage : APage
{
    lazy var activeUser = ActiveUser.singleton
    
    @IBOutlet var emailInput : CBREmailInputView!
    @IBOutlet var phoneInput : CBRTextInputView!
    @IBOutlet var passwordInput : CBRPasswordInputView!
    @IBOutlet var loginButton : CBRButton!
    @IBOutlet var forgotPasswordButton : CBRButton!
    
    override func getBackPage() -> IPage? { return LandingPage() }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        title = "Login to Calibrr"
        emailInput.autoValid = false
        phoneInput.autoValid = false
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        Tracking.Track("loginOpen")
    }
    
    @IBAction func clickLogin(sender: UIButton)
    {
        Tracking.Track("loginClickLogin")
        
        if !validateAndShow() {
            Alert.Error(message: "Please enter all required fields!", from: self)
            return
        }
        
        let email = emailInput.getInput()
        let phone = phoneInput.getInput()
        let password = passwordInput.getInput()!
        
        attemptLogin(email, phone: phone, password, email != nil)
    }
    
    @IBAction func clickForgotPassword(sender: UIButton)
    {
        nav.push(ForgotPasswordPage())
    }
    
    private func validateAndShow() -> Bool
    {
        var isValidEmail: Bool = false
        var isValidPhone: Bool = false
        
        isValidEmail = emailInput.validateAndShow()
        isValidPhone = phoneInput.validateAndShow()
        
        return isValidEmail && isValidPhone && passwordInput.validateAndShow()
    }
    
    private func attemptLogin(_ email: String?, phone: String?, _ password: String, _ usingEmail: Bool)
    {
        let usernameType = usingEmail ? "1" : "2"
        
        loginButton.showWaiting()
        forgotPasswordButton.isEnabled = false
        
        AuthenticationAPI.loginUser(loginAuth: LoginAuth(email: email, phone: phone, password: password)).then { result -> Promise<(LoginUser, User)>  in
            return self.getUserProfile(result)
        }.then{ (result, profile) in
            self.activeUser.login(self.nav, email ?? phone ?? "", password, usernameType, result.token, Date(), false, profile)
        }.ensure {
            self.loginButton.showNormal()
            self.forgotPasswordButton.isEnabled = true
        }.catch { e in
            self.activeUser.showLoginError(self.nav, e)
        }
    }
    
    private func getUserProfile(_ result: LoginUser) -> Promise<(LoginUser, User)>
    {
        //TODO: fix at some point
        OpenAPIClientAPI.customHeaders[APIKeys.HTTP_AUTHORIZATION_HEADER] = APIKeys.HTTP_AUTHORIZATION_PREFIX + result.token
       
        return ProfileAPI.getUser(id: result.user.id).map{ profile in
            return (result, profile)
        }
    }
}
