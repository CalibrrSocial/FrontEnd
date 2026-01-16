//
//  SettingsPage.swift
//  Calibrr
//
//  Created by Kamil Chmurzynski on 19/06/2019.
//  Copyright © 2019 Calibrr. All rights reserved.
//

import UIKit
import SnapKit
import MessageUI
import OpenAPIClient
import NVActivityIndicatorView

class SettingsPage : APage, UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate
{
    lazy var activeUser = ActiveUser.singleton
    
    @IBOutlet var tableView : CBRTableView!
    
    let dataService = DatabaseService.singleton
    let ghostMost = "Ghost Mode"
    private let settingsTitles = ["", "Info", "Account Settings"]
    private lazy var settingsItems = [["Rate Calibrr",
                                       "Send Feedback",
                                       "Recommend Calibrr",
                                       "Share my Profile"],
                                      ["Terms & Conditions",
                                       "Privacy Policy",
                                       "EULA"],
                                      [self.ghostMost,
                                       "My Account"]]
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        title = "Settings"
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        Tracking.Track("settingsOpen")
    }
    
    override func refreshUI()
    {
        super.refreshUI()
        
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                UIApplication.shared.open(URL(string: APIKeys.URL_APPSTORE_REVIEW)!)
            }else if indexPath.row == 1 {
                if MFMailComposeViewController.canSendMail() {
                    let c = MFMailComposeViewController()
                    c.mailComposeDelegate = self
                    c.setSubject("Calibrr Feedback")
                    c.setToRecipients([APIKeys.EMAIL_FEEDBACK])
                    
                    present(c, animated: true)
                }else{
                    Alert.Error(message: "You don't seem to have a way of sending e-mails!")
                }
            }else if indexPath.row == 2 {
                ShareActivity.shared.share()
            }else if indexPath.row == 3 {
                Alert.Basic(message: "TODO: Share my Profile")
            }
        }else if indexPath.section == 1 {
            let p = WebPage()
            if indexPath.row == 0 {
                p.url = APIKeys.URL_TERMS
            }else if indexPath.row == 1 {
                p.url = APIKeys.URL_POLICY
            }else{
                p.url = APIKeys.URL_EULA
            }
            present(p, animated: true)
        }else if indexPath.section == 2 {
            if indexPath.row == 0 {
                //                nav.push(BlockUsersPage())
            }else if indexPath.row == 1 {
                nav.push(MyAccountPage())
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return settingsTitles.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return settingsItems[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SingleLineCell.self), for: indexPath) as! SingleLineCell
        let item = settingsItems[indexPath.section][indexPath.row]
        cell.setup(indexPath, item)
        cell.isHiddenSwitchControl = item != ghostMost
        cell.ghostMode = dataService.getProfile().user.ghostMode ?? false
        cell.switchChanged = { [weak self] isOn in
            self?.updateGhostMode(isOn)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return settingsItems[section].count == 0 ? 0 : 50
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        if settingsItems[section].count == 0 {
            return nil
        }
        
        let header = Bundle.main.loadNibNamed("CBRStandardHeaderView", owner: nil, options: nil)!.first as! CBRStandardHeaderView
        header.setup(settingsTitles[section])
        
        return header
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?)
    {
        controller.dismiss(animated: true)
    }
    
    private func updateGhostMode(_ ghostMode: Bool) {
        var user = dataService.getProfile().user
        user.ghostMode = ghostMode
        
        // Ensure personalInfo is initialized to preserve all fields
        if user.personalInfo == nil {
            user.personalInfo = UserPersonalInfo()
        }
        
        // Ensure socialInfo is initialized to preserve all fields
        if user.socialInfo == nil {
            user.socialInfo = UserSocialInfo()
        }
        
        self.showLoadingView()
        ProfileAPI.updateUserProfile(id: user.id, user: user).thenInAction{ user in
            self.dataService.updateAccount(user)
            self.hideLoadingView()
            self.tableView.reloadData()
        }.catchCBRError(show: true, from: self)
    }
}

extension UIViewController {
    func showLoadingView() {
        DispatchQueue.main.async {
            NVActivityIndicatorPresenter.sharedInstance.startAnimating(.init(type: .circleStrokeSpin))
        }
    }
    
    func hideLoadingView() {
        DispatchQueue.main.async {
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
        }
    }
}

extension UIView {
    func showLoadingView() {
        DispatchQueue.main.async {
            NVActivityIndicatorPresenter.sharedInstance.startAnimating(.init(type: .circleStrokeSpin))
        }
    }
    
    func hideLoadingView() {
        DispatchQueue.main.async {
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
        }
    }
}
