//
//  AlertManager.swift
//  Calibrr
//
//  Created by AI Assistant on 2025-09-18.
//

import UIKit

class AlertManager {
    static let shared = AlertManager()
    
    private init() {}
    
    private weak var currentAlert: UIAlertController?
    private let alertQueue = DispatchQueue(label: "com.calibrr.alerts", attributes: .concurrent)
    
    func showAlert(
        on viewController: UIViewController,
        title: String?,
        message: String?,
        style: UIAlertController.Style = .alert,
        actions: [UIAlertAction]? = nil,
        sourceView: UIView? = nil,
        completion: (() -> Void)? = nil
    ) {
        alertQueue.async(flags: .barrier) { [weak self] in
            DispatchQueue.main.async {
                // Dismiss any existing alert first
                if let existingAlert = self?.currentAlert {
                    existingAlert.dismiss(animated: false) {
                        self?.presentNewAlert(
                            on: viewController,
                            title: title,
                            message: message,
                            style: style,
                            actions: actions,
                            sourceView: sourceView,
                            completion: completion
                        )
                    }
                } else {
                    self?.presentNewAlert(
                        on: viewController,
                        title: title,
                        message: message,
                        style: style,
                        actions: actions,
                        sourceView: sourceView,
                        completion: completion
                    )
                }
            }
        }
    }
    
    private func presentNewAlert(
        on viewController: UIViewController,
        title: String?,
        message: String?,
        style: UIAlertController.Style,
        actions: [UIAlertAction]?,
        sourceView: UIView?,
        completion: (() -> Void)?
    ) {
        // Find the topmost view controller
        var topVC = viewController
        while let presented = topVC.presentedViewController {
            topVC = presented
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        
        // Add actions or default OK button
        if let actions = actions, !actions.isEmpty {
            actions.forEach { alert.addAction($0) }
        } else {
            alert.addAction(UIAlertAction(title: "OK", style: .default))
        }
        
        // Configure for iPad
        if style == .actionSheet {
            if let popover = alert.popoverPresentationController {
                if let sourceView = sourceView {
                    popover.sourceView = sourceView
                    popover.sourceRect = sourceView.bounds
                } else {
                    popover.sourceView = topVC.view
                    popover.sourceRect = CGRect(x: topVC.view.bounds.midX, y: topVC.view.bounds.midY, width: 0, height: 0)
                }
            }
        }
        
        currentAlert = alert
        
        topVC.present(alert, animated: true, completion: completion)
    }
    
    func dismissCurrentAlert(completion: (() -> Void)? = nil) {
        DispatchQueue.main.async { [weak self] in
            if let alert = self?.currentAlert {
                alert.dismiss(animated: true, completion: completion)
                self?.currentAlert = nil
            } else {
                completion?()
            }
        }
    }
    
    // Convenience methods
    func showSuccessAlert(
        on viewController: UIViewController,
        message: String,
        completion: (() -> Void)? = nil
    ) {
        showAlert(
            on: viewController,
            title: "Success",
            message: message,
            actions: [
                UIAlertAction(title: "OK", style: .default) { _ in
                    completion?()
                }
            ]
        )
    }
    
    func showErrorAlert(
        on viewController: UIViewController,
        message: String,
        completion: (() -> Void)? = nil
    ) {
        showAlert(
            on: viewController,
            title: "Error",
            message: message,
            actions: [
                UIAlertAction(title: "OK", style: .default) { _ in
                    completion?()
                }
            ]
        )
    }
    
    func showLoadingAlert(
        on viewController: UIViewController,
        message: String
    ) {
        showAlert(
            on: viewController,
            title: message,
            message: nil,
            actions: [] // No actions for loading alert
        )
    }
}
