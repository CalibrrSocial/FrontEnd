//
//  CBRProfilePhotoView.swift
//  Calibrr
//
//  Created by Kamil Chmurzynski on 18/06/2019.
//  Copyright © 2019 Calibrr. All rights reserved.
//

import Foundation
import SnapKit

class CBRProfilePhotoView : UIImageView
{
    private var initialsBackground : UIView? = nil
    private var initialsLabel : UILabel? = nil
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        setup()
    }
    
    private func setup()
    {
        contentMode = .scaleAspectFill
        clipsToBounds = true
        layer.cornerRadius = min(bounds.width, bounds.height) / 2.0
        layer.masksToBounds = true
        layer.borderWidth = 0
        image = #imageLiteral(resourceName: "icon_avatar_placeholder")
        
        isUserInteractionEnabled = false
        setupLabels()
    }
    
    func setImage(photo: UIImage)
    {
        initialsBackground?.isHidden = true
        image = photo
    }

    func setPerson(firstName: String?, lastName: String?)
    {
        if let firstName = firstName {
            if let lastName = lastName {
                showInitials(initials: "\(firstName.prefix(1)) \(lastName.prefix(1))")
            }else{
                showInitials(initials: "\(firstName.prefix(1))")
            }
        }else if let lastName = lastName {
            showInitials(initials: "\(lastName.prefix(1))")
        }else{
            showInitials(initials: "?")
        }
    }
    
    private func setupLabels()
    {
        if initialsBackground != nil {
            return
        }
        
        initialsBackground = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        initialsBackground!.backgroundColor = .white
        
        addSubview(initialsBackground!)
        
        initialsBackground!.snp.makeConstraints({ (make) in
            make.edges.equalToSuperview()
        })
        
        initialsLabel = UILabel()
        initialsLabel!.backgroundColor = .white
        initialsLabel!.textAlignment = .center
        initialsLabel!.font = UIFont.boldSystemFont(ofSize: 34)
        
        initialsBackground!.addSubview(initialsLabel!)
        
        initialsLabel!.snp.makeConstraints({ (make) in
            make.edges.equalToSuperview()
        })
        initialsBackground!.isHidden = true
    }
    
    private func showInitials(initials: String)
    {
        initialsBackground?.isHidden = false
        initialsLabel?.text = initials
        image = nil
    }
}
