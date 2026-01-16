//
//  CreateAccountPage.swift
//  Calibrr
//
//
//  Copyright © Calibrr. All rights reserved.
//

import OpenAPIClient
import PromiseKit

class CreateAccountPage : APage
{
    lazy var activeUser = ActiveUser.singleton
    
    @IBOutlet var firstNameInput : CBRTextInputView!
    @IBOutlet var lastNameInput : CBRTextInputView!
    @IBOutlet var emailInput : CBREmailInputView!
    @IBOutlet var phoneInput : CBRTextInputView!
    @IBOutlet var passwordInput : CBRPasswordInputView!
    @IBOutlet var passwordRepeatInput : CBRRepeatInputView!
    @IBOutlet var confirmButton : CBRButton!
    @IBOutlet var dobInput : CBRDateInputView!
    
    @IBOutlet var checkBox : UIButton!
    @IBOutlet var checkBoxLabel : UILabel!
    @IBOutlet var checkBoxRedBox : UIView!
    @IBOutlet var checkBoxRedBoxWidthConstraint : NSLayoutConstraint!
    @IBOutlet var checkBoxRedBoxHeightConstraint : NSLayoutConstraint!
    
    private var checked = false
    private var checkBoxRedStartingWidth : CGFloat = 0
    
    /// Track if we came from the create profile flow
    private var hasPendingProfile: Bool {
        return PendingProfileData.shared.hasPendingData
    }
    
    override func getBackPage() -> IPage? {
        // If we have pending profile data, go back to CreateProfilePage
        if hasPendingProfile {
            return CreateProfilePage()
        }
        return LandingPage()
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        title = "Sign Up with Calibrr"
        
        checkBoxRedStartingWidth = checkBoxRedBoxWidthConstraint.constant
        checkBoxRedBox.isHidden = true
        
        let checkBoxString = NSMutableAttributedString(string: "I agree to the ", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)])
        checkBoxString.append(NSMutableAttributedString(string: "Terms & Conditions", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue]))
        checkBoxString.append(NSMutableAttributedString(string: "\nand ", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]))
        checkBoxString.append(NSMutableAttributedString(string: "Privacy Policy", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue]))
        
        checkBoxLabel.attributedText = checkBoxString
        
        firstNameInput.inputDelegate = self
        lastNameInput.inputDelegate = self
        dobInput.setupDate(startDate: Date(fromString: "2010-01-01", format: .isoDate) ?? Date(), datePickerMode: .date, maxDate: Date())
        dobInput.isLimitAge = true
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        Tracking.Track("createAccountOpen")
    }
    
    @IBAction func clickShowTerms(sender: UIButton)
    {
        Tracking.Track("createAccountsClickShowTerms")
        
        let p = WebPage()
        p.url = APIKeys.URL_TERMS
        
        present(p, animated: true)
    }
    
    @IBAction func clickShowPolicy(sender: UIButton)
    {
        Tracking.Track("createAccountsClickShowPolicy")
        
        let p = WebPage()
        p.url = APIKeys.URL_POLICY
        
        present(p, animated: true)
    }
    
    @IBAction func clickCheckTerms(sender: UIButton)
    {
        Tracking.Track("createAccountClickCheckTerms")
        checked = !checked
        updateButtons()
    }
    
    @IBAction func clickCreate(sender: UIButton)
    {
        Tracking.Track("createAccountClickCreate")
        
        if !checked {
            updateButtons()
            animateRedBox()
            return
        }
        
        if !validateAndShow() {
            Tracking.Track("createAccountBadInput")
            Alert.Error(message: "Please enter all required fields!", from: self)
            return
        }
        
        let email = emailInput.getInput()!
        let phone = phoneInput.getInput()!
        let password = passwordInput.getInput()!
        let firstName = firstNameInput.getInput()!
        let lastName = lastNameInput.getInput()!
        if let date = dobInput.getDate() {
            attemptCreateAccount(email, phone, password, firstName, lastName, dob: date.getDateString(true))
        } else {
            attemptCreateAccount(email, phone, password, firstName, lastName, dob: "")
        }
    }
    
    private func validateAndShow() -> Bool
    {
        return emailInput.validateAndShow()
            &&& phoneInput.validateAndShow()
            &&& passwordInput.validateAndShow()
            &&& passwordRepeatInput.validateAndShow()
            &&& firstNameInput.validateAndShow()
            &&& lastNameInput.validateAndShow()
            &&& dobInput.validateAndShow()
    }
    
    private func updateButtons()
    {
        checkBox.setBackgroundImage(checked ? #imageLiteral(resourceName: "checkbox_checked") : #imageLiteral(resourceName: "checkbox_unchecked"), for: .normal)
        checkBoxRedBox.isHidden = checked
    }
    
    private func animateRedBox()
    {
        checkBoxRedBoxWidthConstraint.constant = checkBoxRedStartingWidth * 1.4
        checkBoxRedBoxHeightConstraint.constant = checkBoxRedStartingWidth * 1.4
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        }, completion: { _ in
            self.checkBoxRedBoxWidthConstraint.constant = self.checkBoxRedStartingWidth
            self.checkBoxRedBoxHeightConstraint.constant = self.checkBoxRedStartingWidth
            UIView.animate(withDuration: 0.3, animations: {
                self.view.layoutIfNeeded()
            })
        })
    }
    
    private func attemptCreateAccount(_ email: String, _ phone: String, _ password: String, _ firstName: String, _ lastName: String, dob: String)
    {
        confirmButton.showWaiting()
        
        AuthenticationAPI.registerUser(registerUser: RegisterUser(email: email,
                                                                  phone: phone,
                                                                  password: password,
                                                                  firstName: firstName,
                                                                  lastName: lastName, dob: dob)).then{ result in
            self.getUserProfile(result)
        }.then{ (result, profile) in
            self.activeUser.login(self.nav, email, password, "1", result.token, Date(), false, profile, true)
        }.ensure {
            self.confirmButton.showNormal()
        }.catchCBRError(show: true, from: self)
    }
    
    private func getUserProfile(_ result: LoginUser) -> Promise<(LoginUser, User)>
    {
        //TODO: fix at some point
        OpenAPIClientAPI.customHeaders[APIKeys.HTTP_AUTHORIZATION_HEADER] = APIKeys.HTTP_AUTHORIZATION_PREFIX + result.token
        
        return ProfileAPI.getUser(id: result.user.id).recover { error -> Promise<User> in
            // If user doesn't exist in AWS DynamoDB yet (404), use the basic profile from login
            if case let ErrorResponse.error(statusCode, _, _, _) = error, statusCode == 404 {
                return Promise.value(result.user)
            }
            throw error
        }.map{ profile in
            return (result, profile)
        }
    }
}

extension CreateAccountPage: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == firstNameInput.inputField || textField == lastNameInput.inputField {
            textField.text = textField.text?.capitalizingFirstLetter()
        }
    }
}
