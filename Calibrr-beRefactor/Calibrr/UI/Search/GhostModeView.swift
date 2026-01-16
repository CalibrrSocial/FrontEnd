//
//  GhostModeView.swift
//  Calibrr
//
//  Created by ZVN20210023 on 03/10/2022.
//  Copyright © 2022 Calibrr. All rights reserved.
//

import Foundation
import UIKit
import OpenAPIClient

class GhostModeView: UIView, NibOwnerLoadable {
    
    @IBOutlet weak var switchGhostMode: UISwitch!
    
    var updateUIView: (() -> Void)?
    
    let dataService = DatabaseService.singleton
    
    var ghostMode: Bool = true {
        didSet {
            switchGhostMode.isOn = ghostMode
        }
    }
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    
    private func setupView() {
        self.loadNibContent()
    }
    
    @IBAction func switchChange(_ sender: Any) {
        self.ghostMode = !ghostMode
        self.updateGhostMode(ghostMode)
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
            self.updateUIView?()
        }.catchCBRError(show: true, from: self.parentViewController)
        
        if !ghostMode {
            ActiveUser.singleton.startUpdateLocation()
        }
    }
}

