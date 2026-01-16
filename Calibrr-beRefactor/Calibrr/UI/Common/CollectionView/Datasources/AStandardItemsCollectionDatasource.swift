//
//  AStandardItemsCollectionDatasource.swift
//  Calibrr
//
//  Created by Kamil Chmurzynski on 20/06/2019.
//  Copyright © 2019 Calibrr. All rights reserved.
//

import UIKit

class AStandardItemsCollectionDatasource<U,T> : AItemsCollectionDatasource<T> where U: ACollectionCell<T>
{
    override func getCell(collectionView: UICollectionView, indexPath: IndexPath, item: T) -> UICollectionViewCell
    {
        return collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: U.self), for: indexPath) as! U
    }
    
    override func setup(cell: UICollectionViewCell, item: T, indexPath: IndexPath)
    {
        let c = cell as! U
        c.setup(indexPath, item)
    }
}
