//
//  MyAccountPage.swift
//  Calibrr
//
//
//  Copyright © Calibrr. All rights reserved.
//

import UIKit
import SnapKit
import OpenAPIClient

class MyAccountPage : APage, UITableViewDataSource, UITableViewDelegate
{
    lazy var activeUser = ActiveUser.singleton
    
    @IBOutlet var tableView : CBRTableView!
    
    private let settingsTitles = ["", "Calibrr Prime", "Delete"]
    private var settingsItems = [["Blocked Users",
                                  "Reset Password",
                                  "Log Out"],
                                 ["Restore Purchases"],
                                 ["Delete my Account"]]
    
    override func getBackPage() -> IPage? { return SettingsPage() }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        title = "My Account"
        
        //TODO: add "Cancel Calibrr Prime" if user has it to Subscription
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        Tracking.Track("myAccountOpen")
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
                nav.push(BlockUsersPage())
            }else if indexPath.row == 1 {
                nav.push(ResetPasswordPage())
            }else if indexPath.row == 2 {
                proceedLogout()
            }
        }else if indexPath.section == 1 {
            Alert.Basic(message: "TODO: Restore Purchases")
        }else if indexPath.section == 2 {
            Alert.Choice(title: "Delete Account", message: "Are you sure you want to delete your account?", actionTitle: "Delete Account", actionDestructive: true, cancelTitle: "Cancel", from: self, completionHandler: {
                self.proceedDeleteAccount()
            })
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
        cell.setup(indexPath, settingsItems[indexPath.section][indexPath.row])
        
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
    
    private func proceedLogout()
    {
        activeUser.logOut()
        
        nav.viewControllers = [LandingPage(), self]
        nav.pop()
    }
    
    private func proceedDeleteAccount()
    {
        nav.showTransparentLoading()
        
        AuthenticationAPI.removeUser(id: DatabaseService.singleton.getProfile().user.id).done{
            self.proceedLogout()
        }.ensure{
            self.nav.hideTransparentLoading()
        }.catchCBRError(show: true, from: self)
    }
}
