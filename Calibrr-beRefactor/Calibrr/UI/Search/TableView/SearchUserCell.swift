//
//  SearchUserCell.swift
//  Calibrr
//
//  Created by Kamil Chmurzynski on 18/06/2019.
//  Copyright © 2019 Calibrr. All rights reserved.
//

import UIKit
import SDWebImage
import OpenAPIClient

class SearchUserCell: ACell<User>
{
    @IBOutlet var backgroundTextView: UIView!
    @IBOutlet var background: UIView!
    @IBOutlet var profilePic : UIImageView!
    @IBOutlet var profileNameLabel : UILabel!
    @IBOutlet weak var schoolNameLabel: UILabel!
    @IBOutlet weak var oranizationLabel: UILabel!
    @IBOutlet weak var rightIcon: UIImageView!
    @IBOutlet weak var areaStudying: UILabel!
    @IBOutlet weak var courses: UILabel!
    @IBOutlet weak var team: UILabel!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        background.roundCorners()
        profilePic.roundFull()
        backgroundTextView.roundCorners(30, top: false)
        rightIcon.tintColor = UIColor(red: 20, green: 20, blue: 20, alpha: 1.0)
        profilePic.contentMode = .scaleAspectFit
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        profilePic.sd_cancelCurrentImageLoad()
    }
    
    override func setup(_ indexPath: IndexPath, _ item: User)
    {
        super.setup(indexPath, item)
        
        if let image = item.pictureProfile, !image.isEmpty,
           let url = URL(string: image) {
            profilePic.sd_setImage(with: url, placeholderImage: UIImage(named: "icon_avatar_placeholder"), context: nil)
        } else {
            profilePic.image = UIImage(named: "icon_avatar_placeholder")
        }
        var dob = getDOB(item)
        let name = item.firstName + " " + item.lastName
        
        if !dob.isEmpty {
            dob = ", \(dob)"
        }
        
        let attributsBold = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16, weight: .bold)]
        let attributsNormal = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16, weight: .regular)]
        let attributedString = NSMutableAttributedString(string: name, attributes:attributsBold)
        let normalPart = NSMutableAttributedString(string: dob, attributes:attributsNormal)
        attributedString.append(normalPart)
        
        profileNameLabel.attributedText = attributedString
        
        if let education = item.personalInfo?.education,
           !education.isEmpty {
            schoolNameLabel.isHidden = false
            schoolNameLabel.text = education
        } else {
            schoolNameLabel.isHidden = true
        }
        
        if let greekLife = item.personalInfo?.greekLife,
           !greekLife.isEmpty {
            oranizationLabel.isHidden = false
            oranizationLabel.text = greekLife
        } else {
            oranizationLabel.isHidden = true
        }
        
        if let studying = item.personalInfo?.studying,
           let currentStudying = DatabaseService.singleton.getProfile().user.personalInfo?.studying,
            studying == currentStudying {
            areaStudying.isHidden = false
            areaStudying.text = studying
        } else {
            areaStudying.isHidden = true
        }
        
        
        if let club = item.personalInfo?.club,
           let name = club.club,
           !name.isEmpty,
           let number = club.number,
           !number.isEmpty {
            team.isHidden = false
            team.text = "\(name) #\(number)"
        } else {
            team.isHidden = true
        }
        
        if !item.myCourses.isEmpty {
            courses.isHidden = false
            courses.text = item.myCourses.compactMap({ $0.name }).joined(separator: ", ")
        } else {
            courses.isHidden = true
        }
    }
    
    private func getDOB(_ item: User) -> String
    {
        if let age = item.personalInfo?.dob.date?.age() {
            return isAboveAgeLimit(age) ? "\(age)" : ""
        }
        return ""
    }
    
    private func isAboveAgeLimit(_ age: Int) -> Bool
    {
        return age >= 13
    }
}
