//
//  ACollectionCell.swift
//  Calibrr
//
//
//  Copyright © Calibrr. All rights reserved.
//

import UIKit

class ACollectionCell<T> : UICollectionViewCell where T: Any
{
    private var item : T? = nil
    
    open func setup(_ indexPath: IndexPath, _ item: T)
    {
        self.item = item
        makeAccessible("Cell[\(indexPath.section),\(indexPath.row)]")
    }
    
    func getItem() -> T
    {
        return item!
    }
}
