//
//  ResetPasswordPage.swift
//  Calibrr
//
//  Created by Kamil Chmurzynski on 19/06/2019.
//  Copyright © 2019 Calibrr. All rights reserved.
//

import UIKit
import OpenAPIClient

class ResetPasswordPage : APage
{
    @IBOutlet var oldPasswordInput : CBRPasswordInputView!
    @IBOutlet var newPasswordInput : CBRPasswordInputView!
    @IBOutlet var newPasswordRepeatInput : CBRRepeatInputView!
    @IBOutlet var confirmButton : CBRButton!
    
    override func getBackPage() -> IPage? { return MyAccountPage() }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        title = "Reset Your Password"
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        Tracking.Track("resetPasswordOpen")
    }
    
    @IBAction func clickConfirm(_ sender: UIButton)
    {
        Tracking.Track("resetPasswordClickConfirm")
        
        if !validateAndShow() {
            Tracking.Track("resetPasswordBadInput")
            Alert.Error(message: "Please enter all required fields!", from: self)
            return
        }
        
        let oldPassword = oldPasswordInput.getInput()!
        let newPassword = newPasswordInput.getInput()!
        
        attemptPasswordReset(oldPassword, newPassword)
    }
    
    private func validateAndShow() -> Bool
    {
        return oldPasswordInput.validateAndShow()
            &&& newPasswordInput.validateAndShow()
            &&& newPasswordRepeatInput.validateAndShow()
    }
    
    private func attemptPasswordReset(_ oldPassword: String, _ newPassword: String)
    {
        confirmButton.showWaiting()
        
        AuthenticationAPI.changePassword(changePassword: ChangePassword(oldPassword: oldPassword, newPassword: newPassword)).done{ _ in
            self.processPasswordReset()
        }.ensure {
            self.confirmButton.showNormal()
        }.catch{ _ in
            Alert.Basic(title: "Try Again", message: "Your Old Password is incorrect. You must've entered it incorrectly, please try again")
        }
    }
    
    private func processPasswordReset()
    {
        nav.pop()
        Alert.Basic(title: "Success!", message: "Password has been reset successfully")
    }
}
