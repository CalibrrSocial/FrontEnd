//
//  ForgotPasswordPage.swift
//  Calibrr
//
//
//  Copyright © Calibrr. All rights reserved.
//

import UIKit
import PromiseKit
import OpenAPIClient

class ForgotPasswordPage : APage
{
    @IBOutlet var emailInput : CBREmailInputView!
    @IBOutlet var confirmButton : CBRButton!
    
    override func getBackPage() -> IPage? { return LoginPage() }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        title = "Password Recovery"
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        Tracking.Track("forgotPasswordOpen")
    }
    
    @IBAction func clickConfirm(sender: UIButton)
    {
        Tracking.Track("forgotPasswordClickConfirm")
        
        if !validateAndShow() {
            Alert.Error(message: "Please enter all required fields!", from: self)
            return
        }
        
        let email = emailInput.getInput()!
        
        attemptForgotPassword(email)
    }
    
    private func validateAndShow() -> Bool
    {
        return emailInput.validateAndShow()
    }
    
    private func attemptForgotPassword(_ email: String)
    {
        confirmButton.showWaiting()
        
        AuthenticationAPI.forgotPassword(username: email).done{ _ in
            self.processForgotPassword()
        }.ensure{
            self.confirmButton.showNormal()
        }.catchCBRError(show: true, from: self)
    }
    
    private func processForgotPassword()
    {
        Alert.Basic(title: "CHECK YOUR SPAM FOLDER", message: "Your new password has been sent your email", actionTitle: "OK", from: self) {
            self.backAction()
        }
    }
}
