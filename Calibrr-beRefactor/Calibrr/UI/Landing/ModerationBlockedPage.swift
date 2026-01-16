//
//  ModerationBlockedPage.swift
//  Calibrr
//
//  Created by System on 2025-01-25.
//  Copyright © 2025 Calibrr. All rights reserved.
//

import UIKit
import SnapKit

class ModerationBlockedPage: APage {
    
    private var moderationState: String = ""
    private var moderationReason: String?
    private var suspensionEndsAt: String?
    
    private let backgroundView = UIView()
    private let contentView = UIView()
    private let headerLabel = UILabel()
    private let messageLabel = UILabel()
    private let disputeButton = UIButton()
    
    init(moderationState: String, moderationReason: String?, suspensionEndsAt: String? = nil) {
        self.moderationState = moderationState
        self.moderationReason = moderationReason
        self.suspensionEndsAt = suspensionEndsAt
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func showsNavigationBar() -> Bool { return false }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureContent()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if moderationState == "banned" {
            Tracking.Track("moderationBannedPageOpen")
        } else if moderationState == "suspended" {
            Tracking.Track("moderationSuspendedPageOpen")
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .black
        
        // Create Calibrr gradient background
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(red: 0.2, green: 0.4, blue: 0.8, alpha: 1.0).cgColor,  // Calibrr blue
            UIColor(red: 0.6, green: 0.2, blue: 0.8, alpha: 1.0).cgColor   // Calibrr purple
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        backgroundView.layer.insertSublayer(gradientLayer, at: 0)
        
        view.addSubview(backgroundView)
        backgroundView.addSubview(contentView)
        contentView.addSubview(headerLabel)
        contentView.addSubview(messageLabel)
        contentView.addSubview(disputeButton)
        
        // Background view constraints
        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // Update gradient frame when view layout changes
        backgroundView.layoutIfNeeded()
        gradientLayer.frame = view.bounds
        
        // Content view constraints
        contentView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.left.right.equalToSuperview().inset(40)
        }
        
        // Header label setup
        headerLabel.textColor = .white
        headerLabel.font = UIFont.boldSystemFont(ofSize: 24)
        headerLabel.textAlignment = .center
        headerLabel.numberOfLines = 0
        
        headerLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.right.equalToSuperview()
        }
        
        // Message label setup
        messageLabel.textColor = .white
        messageLabel.font = UIFont.systemFont(ofSize: 16)
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        
        messageLabel.snp.makeConstraints { make in
            make.top.equalTo(headerLabel.snp.bottom).offset(30)
            make.left.right.equalToSuperview()
        }
        
        // Dispute button setup
        disputeButton.setTitle("To dispute this, visit Calibrr.com to reach out", for: .normal)
        disputeButton.setTitleColor(.white, for: .normal)
        disputeButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        disputeButton.titleLabel?.numberOfLines = 0
        disputeButton.titleLabel?.textAlignment = .center
        disputeButton.addTarget(self, action: #selector(disputeButtonTapped), for: .touchUpInside)
        
        // Add underline to make it look like a hyperlink
        let attributedString = NSMutableAttributedString(string: "To dispute this, visit Calibrr.com to reach out")
        attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: attributedString.length))
        disputeButton.setAttributedTitle(attributedString, for: .normal)
        
        disputeButton.snp.makeConstraints { make in
            make.top.equalTo(messageLabel.snp.bottom).offset(40)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    private func configureContent() {
        if moderationState == "banned" {
            headerLabel.text = "You have been banned from Calibrr Social."
            messageLabel.text = ""
        } else if moderationState == "suspended" {
            headerLabel.text = "You have been temporarily suspended from Calibrr Social."
            
            if let suspensionEndsAt = suspensionEndsAt {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                
                if let suspensionDate = dateFormatter.date(from: suspensionEndsAt) {
                    let displayFormatter = DateFormatter()
                    displayFormatter.dateStyle = .medium
                    displayFormatter.timeStyle = .short
                    
                    messageLabel.text = "You will be unsuspended starting on \(displayFormatter.string(from: suspensionDate))"
                } else {
                    messageLabel.text = "You will be unsuspended soon."
                }
            } else {
                messageLabel.text = "You will be unsuspended soon."
            }
        }
    }
    
    @objc private func disputeButtonTapped() {
        Tracking.Track("moderationDisputeButtonTapped")
        
        // Open Calibrr.com in Safari
        if let url = URL(string: "https://calibrr.com") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Update gradient frame when view layout changes
        if let gradientLayer = backgroundView.layer.sublayers?.first as? CAGradientLayer {
            gradientLayer.frame = backgroundView.bounds
        }
    }
}
