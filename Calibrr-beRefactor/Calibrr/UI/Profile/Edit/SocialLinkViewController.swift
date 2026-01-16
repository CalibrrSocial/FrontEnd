//
//  SocialLinkViewController.swift
//  Calibrr
//
//  Created by ZVN20210023 on 08/02/2023.
//  Copyright © 2023 Calibrr. All rights reserved.
//

import UIKit

protocol SocialLinkViewControllerDelegate {
    func socialAccount(_ account: [SocialItemData])
}

class SocialLinkViewController: UIViewController, DrawerPresentable, SocialLinkDelegate {
    var heightOfPartiallyExpandedDrawer: CGFloat = 250

    @IBOutlet weak var imageBack: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var iconEditModeImageView: UIImageView!
    @IBOutlet weak var saveButton: CBRButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var textFieldView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var socialLinkView: SocialLink!
    @IBOutlet weak var editView: UIView!
    @IBOutlet weak var doneButton: UIButton!
    
    var delegate: SocialLinkViewControllerDelegate?
    
    var currentItem: SocialItemData? = nil
    var validItems: [SocialItemData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        openItem(item: currentItem)
        openEditMode(false)
    }
    
    init(item: SocialItemData?,
         validItems: [SocialItemData]) {
        self.currentItem = item
        self.validItems = validItems
        super.init(nibName: "SocialLinkViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        containerView.layer.cornerRadius = 8.0
        containerView.clipsToBounds = true
        socialLinkView.items = [SocialItemData(.instagarm), SocialItemData(.vsco), SocialItemData(.snapchat), SocialItemData(.x), SocialItemData(.linkedin), SocialItemData(.tiktok), SocialItemData(.facebook)]
        socialLinkView.reloadData()
        socialLinkView.delegate = self
        backButton.setTitle(nil, for: .normal)
        openEditMode(false)
        
        for item in validItems {
            if let index = socialLinkView.items.firstIndex(where: { $0.type == item.type }) {
                socialLinkView.items[index].account = item.account
            }
        }
    }
    
    @IBAction func back(_ sender: Any) {
        openEditMode(false)
    }
    
    @IBAction func done(_ sender: Any) {
        dismissView()
    }
    
    @IBAction func save(_ sender: Any) {
        self.currentItem?.account = textField.text ?? ""
        if let index = self.socialLinkView.items.firstIndex(where: { $0.type == self.currentItem?.type }) {
            self.socialLinkView.items[index].account = textField.text ?? ""
        }
        self.textField.resignFirstResponder()
//        openEditMode(false)
        dismissView()
    }
    
    func dismissView() {
        DispatchQueue.main.async {
            self.delegate?.socialAccount(self.socialLinkView.getValidAccount())
            self.dismiss(animated: true)
        }
    }
    
    func didTapOnItem(item: SocialItemData?) {
        openItem(item: item)
    }
    
    private func openItem(item: SocialItemData?) {
        self.currentItem = item
        if let socialItem = item {
            iconEditModeImageView.image = UIImage(named: socialItem.type.rawValue)
            textField.text = socialItem.account
            openEditMode(true)
            messageLabel.text = "Optional: Consider setting your \((self.currentItem?.type.value ?? "").capitalized) to ‘Public’ and not ‘Private’ so more people can check you out!"
        }
    }
    
    private func openEditMode(_ isEditMode: Bool) {
        backButton.isHidden = !isEditMode
        editView.isHidden = !isEditMode
        imageBack.isHidden = !isEditMode
        socialLinkView.isHidden = isEditMode
        doneButton.isHidden = isEditMode
    }
}
