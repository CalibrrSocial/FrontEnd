//
//  AStandardItemsDatasource.swift
//  Calibrr
//
//
//  Copyright © Calibrr. All rights reserved.
//

import UIKit

class AStandardItemsDatasource<U,T> : AItemsDatasource<T> where U: ACell<T>
{
    override func getCell(tableView: UITableView, indexPath: IndexPath, item: T) -> UITableViewCell
    {
        return tableView.dequeueReusableCell(withIdentifier: String(describing: U.self), for: indexPath) as! U
    }
    
    override func setup(cell: UITableViewCell, item: T, indexPath: IndexPath)
    {
        let c = cell as! U
        c.setup(indexPath, item)
    }
}
