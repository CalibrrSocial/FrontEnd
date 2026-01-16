//
//  CBRTableView.swift
//  Calibrr
//
//  Created by Kamil Chmurzynski on 18/06/2019.
//  Copyright © 2019 Calibrr. All rights reserved.
//

import UIKit

protocol CBRTableViewDelegate {
    func refreshData()
}

class CBRTableView : UITableView
{
    public var emptyView: UIView? = nil
    private var noContentView : UIView? = nil
    private var noContentViewLabel : UILabel? = nil
    
    var refreshDelegate: CBRTableViewDelegate?
    
    var isEnableRefresh: Bool = false {
        didSet {
            if isEnableRefresh {
                self.setupRefresh()
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        
        alwaysBounceVertical = true
        
        autoresizingMask = UIView.AutoresizingMask.flexibleWidth.union(.flexibleHeight)
        cellLayoutMarginsFollowReadableWidth = false
        
        separatorStyle = .none
        estimatedRowHeight = 60.0
        rowHeight = UITableView.automaticDimension
        
        let cells = [
            BaseCell.self,
            CommentCell.self,
            SingleLineCell.self,
            SearchUserCell.self,
            ProfileCell.self,
            HeaderProfileCell.self,
            SocialLinkTableViewCell.self]
        
        for cell in cells {
            let cellName = String(describing: cell)
            register(UINib(nibName: cellName, bundle: nil), forCellReuseIdentifier: cellName)
        }
    }
    
    private func setupRefresh() {
        if refreshControl == nil {
            refreshControl = UIRefreshControl()
            refreshControl?.tintColor = .white
            guard let refreshControl = refreshControl else { return }
            refreshControl.addTarget(self, action: #selector(self.refreshData), for: .valueChanged)
            self.addSubview(refreshControl)
        }
    }
    
    @objc func refreshData() {
        self.refreshDelegate?.refreshData()
    }
    
    public func endRefreshing() {
        DispatchQueue.main.async {
            self.beginUpdates()
            self.refreshControl?.endRefreshing()
            self.endUpdates()
        }
    }
    
    override func reloadData()
    {
        super.reloadData()
        if let d = dataSource as? ADatasource, d.hasNoItems() {
            if let view = emptyView {
                addSubview(view)
                view.snp.makeConstraints({ (make) in
                    make.centerX.equalToSuperview()
                    make.top.equalTo(80)
                })
                
            } else if noContentView == nil {
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
                noContentViewLabel?.text = d.noContentMessage
            } else {
                noContentViewLabel?.text = d.noContentMessage
            }
        } else {
            resetEmptyView()
        }
    }
    
    public func resetEmptyView() {
        emptyView?.removeFromSuperview()
        noContentView?.removeFromSuperview()
        noContentView = nil
        emptyView = nil
    }
}
