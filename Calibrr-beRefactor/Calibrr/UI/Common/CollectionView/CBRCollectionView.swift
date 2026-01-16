//
//  CBRCollectionView.swift
//  Calibrr
//
//
//  Copyright © Calibrr. All rights reserved.
//

import UIKit

class CBRCollectionView : UICollectionView
{
    private var noContentView : UIView? = nil
    private var noContentViewLabel : UILabel? = nil
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        
        backgroundColor = .clear
        
        let cells = [
            ProfileSocialMediaCell.self]
        
        for cell in cells {
            let cellName = String(describing: cell)
            register(UINib(nibName: cellName, bundle: nil), forCellWithReuseIdentifier: cellName)
        }
    }
    
    override func reloadData()
    {
        let offset = contentOffset
        super.reloadData()
        layoutIfNeeded()
        setContentOffset(offset, animated: false)
        
        if let d = dataSource as? ACollectionDatasource, d.hasNoItems() {
            if noContentView == nil {
                noContentView = UIView()
                addSubview(noContentView!)
                noContentView!.snp.makeConstraints({ (make) in
                    make.left.right.top.bottom.equalTo(0)
                })
                
                noContentViewLabel = UILabel()
                noContentViewLabel!.setupWhite(textSize: 18)
                noContentViewLabel!.textAlignment = .center
                noContentView?.addSubview(noContentViewLabel!)
                noContentViewLabel!.sizeToFit()
                noContentViewLabel!.snp.makeConstraints({ (make) in
                    make.center.equalTo(self)
                })
            }
            noContentViewLabel?.text = d.noContentMessage
        }else{
            noContentView?.removeFromSuperview()
            noContentView = nil
            noContentViewLabel = nil
        }
    }
}
