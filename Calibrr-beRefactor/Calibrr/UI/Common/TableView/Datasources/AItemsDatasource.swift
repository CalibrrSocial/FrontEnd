//
//  AItemsDatasource.swift
//  Calibrr
//
//  Created by Kamil Chmurzynski on 18/06/2019.
//  Copyright © 2019 Calibrr. All rights reserved.
//

import UIKit

class AItemsDatasource<T> : ADatasource where T: Any
{
    var items = [T]()
    
    func itemAt(_ indexPath: IndexPath) -> T?
    {
        return items[indexPath.row]
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return items.count
    }
    
    override func hasNoItems() -> Bool
    {
        return items.count == 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let item = itemAt(indexPath)!
        let cell = getCell(tableView: tableView, indexPath: indexPath, item: item)
        
        setup(cell: cell, item: item, indexPath: indexPath)
        
        return cell
    }
    
    internal func getCell(tableView: UITableView, indexPath: IndexPath, item: T) -> UITableViewCell
    {
        return UITableViewCell()
    }
    
    internal func setup(cell: UITableViewCell, item: T, indexPath: IndexPath)
    {
    }
}
