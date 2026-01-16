//
//  AItemsCollectionDatasource.swift
//  Calibrr
//
//  Created by Kamil Chmurzynski on 20/06/2019.
//  Copyright © 2019 Calibrr. All rights reserved.
//

import UIKit

class AItemsCollectionDatasource<T> : ACollectionDatasource where T : Any
{
    var items = [T]()
    
    open func getMaxItemsPerSection() -> Int
    {
        return items.count
    }
    
    func itemAt(_ indexPath: IndexPath) -> T?
    {
        return items[indexPath.row]
    }
    
    override func hasNoItems() -> Bool
    {
        return items.count == 0
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int
    {
        let max = getMaxItemsPerSection()
        let count = items.count
        
        guard count > 0 else { return 0}
        
        let sections = count / max
        return sections + (count % max > 0 ? 1 : 0)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        let max = getMaxItemsPerSection()
        let count = items.count
        
        guard count > 0 else { return 0}
        
        let sections = count / max
        
        if section == sections - 1 {
            let remainder = count % max
            return remainder == 0 ? max : remainder
        }
        return max
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let item = itemAt(indexPath)!
        let cell = getCell(collectionView: collectionView, indexPath: indexPath, item: item)
        
        setup(cell: cell, item: item, indexPath: indexPath)
        
        return cell
    }
    
    internal func getCell(collectionView: UICollectionView, indexPath: IndexPath, item: T) -> UICollectionViewCell
    {
        return UICollectionViewCell()
    }
    
    internal func setup(cell: UICollectionViewCell, item: T, indexPath: IndexPath)
    {
    }
}
