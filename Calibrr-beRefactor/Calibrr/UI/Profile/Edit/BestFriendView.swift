//
//  BestFriendView.swift
//  Calibrr
//
//
//  Copyright © Calibrr. All rights reserved.
//

import UIKit
import OpenAPIClient

class BestFriendView: UIView, NibOwnerLoadable {
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var addButton: UIButton!
    
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
    
    public func setupData(_ data: BestFriends) {
        self.firstName.text = data.firstName
        self.lastName.text = data.lastName
    }
    
    @IBAction func share(_ sender: Any) {
        ShareActivity.shared.share()
    }
}
