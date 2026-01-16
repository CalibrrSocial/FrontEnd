//
//  ADatasource.swift
//  Calibrr
//
//
//  Copyright © Calibrr. All rights reserved.
//

import UIKit

class ADatasource : NSObject, UITableViewDataSource
{
    var headerTitle : String? { get{ return nil } }
    var noContentMessage : String {
        get{ return "" }
    }
    
    override init()
    {
        super.init()
        
        reload()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        return headerTitle
    }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        return UITableViewCell()
    }
    
    func reload() { }
    
    func hasNoItems() -> Bool
    {
        return false
    }
}
