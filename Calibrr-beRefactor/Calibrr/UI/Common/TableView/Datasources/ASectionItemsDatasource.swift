//
//  ASectionItemsDatasource.swift
//  Calibrr
//
//
//  Copyright © Calibrr. All rights reserved.
//

import UIKit

class ASectionItemsDatasource<T> : ADatasource where T: Any
{
    internal var items = [[T]]()
    
    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return hasNoItems() ? 0 : items.count
    }
    
    func itemAt(_ indexPath: IndexPath) -> T?
    {
        return items[indexPath.section][indexPath.row]
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return items[section].count
    }
    
    override func hasNoItems() -> Bool
    {
        let count = items.deepCount()
        return count == 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = getCell(tableView, for: indexPath)
        let item = itemAt(indexPath)!
        
        setupCell(cell, item, indexPath)
        
        return cell
    }
    
    internal func getCell(_ tableView: UITableView, for indexPath: IndexPath) -> UITableViewCell
    {
        return UITableViewCell()
    }
    
    internal func setupCell(_ cell: UITableViewCell, _ item: T, _ indexPath: IndexPath)
    {
    }
}
