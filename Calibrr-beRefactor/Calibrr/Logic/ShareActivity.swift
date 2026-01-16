//
//  ShareActivity.swift
//  Calibrr
//
//  Created by ZVN20210023 on 21/02/2023.
//  Copyright © 2023 Calibrr. All rights reserved.
//

import Foundation
import UIKit

class ShareActivity {
    
    static var shared = ShareActivity()
    
    func share() {
        let activityItems = [String(format: "Calibrr is a free, fun, safe, app where you can discover other people near you! Create your profile and link all of your social media in one easy spot!\n%@", "http://apps.apple.com/us/app/calibrr/id1377015871")]
        let excludedActivities: [UIActivity.ActivityType] = [UIActivity.ActivityType.airDrop,
                                                             UIActivity.ActivityType.addToReadingList,
                                                             UIActivity.ActivityType.assignToContact,
                                                             UIActivity.ActivityType.openInIBooks,
                                                             UIActivity.ActivityType.markupAsPDF,
                                                             UIActivity.ActivityType.print,
                                                             UIActivity.ActivityType.saveToCameraRoll]
        let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        activityViewController.excludedActivityTypes = excludedActivities
        if let viewController = UIApplication.shared.keyWindow?.rootViewController {
            viewController.present(activityViewController, animated: true, completion: nil)
        }
    }
}
