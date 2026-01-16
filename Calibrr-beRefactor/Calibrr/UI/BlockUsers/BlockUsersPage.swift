//
//  BlockUsersPage.swift
//  Calibrr
//
//  Created by Kamil Chmurzynski on 19/06/2019.
//  Copyright © 2019 Calibrr. All rights reserved.
//

import UIKit

class BlockUsersPage : APage, UITableViewDelegate
{
    @IBOutlet var resultsTable : CBRTableView!
    
    private let datasource = BlockUsersDatasource()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        title = "Blocked Users"
        
        resultsTable.dataSource = datasource
        
        hideKeyboardWhenTappedAround()
    }
    
    override func refreshUI()
    {
        super.refreshUI()
        
        datasource.reload()
        resultsTable.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        
        //        let p = ProfilePage()
        //        p.user = datasource.itemAt(indexPath)
        //        nav.push(p)
    }
}
